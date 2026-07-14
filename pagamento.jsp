<%--
    Document   : pagamento
    Created on : 15/11/2025, 17:18:29
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Finalizar Compra - SC Rio Tinto</title>
    <link href="css/CssPagamento.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
<%
    // Verificar se o utilizador está logado
    Integer idUtilizador = (Integer) session.getAttribute("id_utilizador");
    String primeiroNome = (String) session.getAttribute("primeiro_nome");
    String ultimoNome = (String) session.getAttribute("ultimo_nome");
    String emailUtilizador = (String) session.getAttribute("email");
    
    if (idUtilizador == null) {
        response.sendRedirect("index.htm");
        return;
    }
    
    String nomeCompleto = (primeiroNome != null && ultimoNome != null) 
        ? primeiroNome + " " + ultimoNome 
        : "Nome não disponível";
    
    if (emailUtilizador == null) {
        emailUtilizador = "Email não disponível";
    }

    // ========== PROCESSAR CHECKOUT ==========
    if (request.getMethod().equals("POST")) {
        try {
            String moradaEnvio = request.getParameter("morada_envio");
            String metodoPagamento = request.getParameter("metodo_pagamento");
            String carrinhoJson = request.getParameter("carrinho_json");
            
            System.out.println("========== CHECKOUT DEBUG ==========");
            System.out.println("ID Utilizador: " + idUtilizador);
            System.out.println("Morada: " + moradaEnvio);
            System.out.println("Método Pagamento: " + metodoPagamento);
            System.out.println("Carrinho JSON: " + carrinhoJson);
            
            // VALIDAÇÃO: Campos obrigatórios
            if (moradaEnvio == null || moradaEnvio.trim().isEmpty()) {
                session.setAttribute("erro_checkout", "Morada de envio é obrigatória");
                response.sendRedirect("pagamento.jsp");
                return;
            }
            
            if (metodoPagamento == null || metodoPagamento.trim().isEmpty()) {
                session.setAttribute("erro_checkout", "Método de pagamento é obrigatório");
                response.sendRedirect("pagamento.jsp");
                return;
            }
            
            if (carrinhoJson == null || carrinhoJson.trim().isEmpty()) {
                session.setAttribute("erro_checkout", "Carrinho está vazio");
                response.sendRedirect("pagamento.jsp");
                return;
            }
            
            // Parse do JSON do carrinho (simples)
            carrinhoJson = carrinhoJson.trim();
            if (!carrinhoJson.startsWith("[") || !carrinhoJson.endsWith("]")) {
                session.setAttribute("erro_checkout", "Formato de carrinho inválido");
                response.sendRedirect("pagamento.jsp");
                return;
            }
            
            // Remover [ e ]
            carrinhoJson = carrinhoJson.substring(1, carrinhoJson.length() - 1);
            
            // Split por objetos
            String[] items = carrinhoJson.split("\\},\\{");
            
            if (items.length == 0) {
                session.setAttribute("erro_checkout", "Nenhum item no carrinho");
                response.sendRedirect("pagamento.jsp");
                return;
            }
            
            // Arrays para armazenar dados
            int[] idsProds = new int[items.length];
            int[] qtds = new int[items.length];
            double[] precos = new double[items.length];
            
            double valorSubtotal = 0;
            
            // Parse manual de cada item
            for (int i = 0; i < items.length; i++) {
                String item = items[i];
                
                // Limpar caracteres
                item = item.replace("{", "").replace("}", "").replace("\"", "");
                
                // Split por vírgula
                String[] props = item.split(",");
                
                int idProd = 0;
                int qtd = 0;
                double preco = 0;
                
                // Extrair propriedades
                for (String prop : props) {
                    String[] kv = prop.split(":");
                    if (kv.length == 2) {
                        String key = kv[0].trim();
                        String value = kv[1].trim();
                        
                        if (key.equals("id_produto") || key.equals("id")) {
                            idProd = Integer.parseInt(value);
                        } else if (key.equals("quantidade")) {
                            qtd = Integer.parseInt(value);
                        } else if (key.equals("preco")) {
                            preco = Double.parseDouble(value);
                        }
                    }
                }
                
                // Validar valores
                if (idProd == 0 || qtd == 0 || preco == 0) {
                    session.setAttribute("erro_checkout", "Item " + (i+1) + " com dados inválidos");
                    response.sendRedirect("pagamento.jsp");
                    return;
                }
                
                idsProds[i] = idProd;
                qtds[i] = qtd;
                precos[i] = preco;
                
                valorSubtotal += preco * qtd;
                
                System.out.println("Item " + (i+1) + ": ID=" + idProd + ", Qtd=" + qtd + ", Preço=" + preco);
            }
            
            double valorIva = valorSubtotal * 0.23;
            double valorTotal = valorSubtotal + valorIva;
            
            System.out.println("Subtotal: " + valorSubtotal);
            System.out.println("IVA: " + valorIva);
            System.out.println("Total: " + valorTotal);
            System.out.println("====================================");
            
            // ========== INSERIR NA BASE DE DADOS ==========
            String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
            String username = "root";
            String password = "";
            
            Connection conn = null;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, username, password);
                conn.setAutoCommit(false);
                
                // 1. INSERIR ENCOMENDA
                String sqlEncomenda = "INSERT INTO t_encomendas (id_utilizador, morada_envio, metodo_pagamento, estado, valor_total, data_encomenda, data_atualizacao) VALUES (?, ?, ?, 'pendente', ?, NOW(), NOW())";
                PreparedStatement stmtEncomenda = conn.prepareStatement(sqlEncomenda, Statement.RETURN_GENERATED_KEYS);
                stmtEncomenda.setInt(1, idUtilizador);
                stmtEncomenda.setString(2, moradaEnvio);
                stmtEncomenda.setString(3, metodoPagamento);
                stmtEncomenda.setDouble(4, valorTotal);
                stmtEncomenda.executeUpdate();
                
                ResultSet rsEncomenda = stmtEncomenda.getGeneratedKeys();
                int idEncomenda = 0;
                if (rsEncomenda.next()) {
                    idEncomenda = rsEncomenda.getInt(1);
                }
                rsEncomenda.close();
                stmtEncomenda.close();
                
                System.out.println("✓ Encomenda criada: ID=" + idEncomenda);
                
                if (idEncomenda == 0) {
                    throw new Exception("Erro ao obter ID da encomenda");
                }
                
                // 2. INSERIR FATURA
                String sqlFatura = "INSERT INTO t_fatura (id_utilizador, id_encomenda, data_emissao, metodo_pagamento, valor_subtotal, valor_iva, valor_desconto) VALUES (?, ?, CURDATE(), ?, ?, ?, 0.00)";
                PreparedStatement stmtFatura = conn.prepareStatement(sqlFatura, Statement.RETURN_GENERATED_KEYS);
                stmtFatura.setInt(1, idUtilizador);
                stmtFatura.setInt(2, idEncomenda);
                stmtFatura.setString(3, metodoPagamento);
                stmtFatura.setDouble(4, valorSubtotal);
                stmtFatura.setDouble(5, valorIva);
                stmtFatura.executeUpdate();
                
                ResultSet rsFatura = stmtFatura.getGeneratedKeys();
                int idFatura = 0;
                if (rsFatura.next()) {
                    idFatura = rsFatura.getInt(1);
                }
                rsFatura.close();
                stmtFatura.close();
                
                System.out.println("✓ Fatura criada: ID=" + idFatura);
                
                // 3. INSERIR ITENS
                String sqlItem = "INSERT INTO t_itens_encomenda (id_encomenda, id_produto, quantidade, preco_unitario, preco_total) VALUES (?, ?, ?, ?, ?)";
                PreparedStatement stmtItem = conn.prepareStatement(sqlItem);
                
                for (int i = 0; i < idsProds.length; i++) {
                    double precoTotal = qtds[i] * precos[i];
                    
                    stmtItem.setInt(1, idEncomenda);
                    stmtItem.setInt(2, idsProds[i]);
                    stmtItem.setInt(3, qtds[i]);
                    stmtItem.setDouble(4, precos[i]);
                    stmtItem.setDouble(5, precoTotal);
                    stmtItem.addBatch();
                    
                    System.out.println("✓ Item " + (i+1) + " preparado");
                }
                
                stmtItem.executeBatch();
                stmtItem.close();
                System.out.println("✓ Todos os itens inseridos");
                
                // 4. ATUALIZAR STOCK
                String sqlUpdateStock = "UPDATE t_produtos SET stock = stock - ? WHERE id_produto = ?";
                PreparedStatement stmtStock = conn.prepareStatement(sqlUpdateStock);
                
                for (int i = 0; i < idsProds.length; i++) {
                    stmtStock.setInt(1, qtds[i]);
                    stmtStock.setInt(2, idsProds[i]);
                    stmtStock.addBatch();
                }
                
                stmtStock.executeBatch();
                stmtStock.close();
                System.out.println("✓ Stock atualizado");
                
                // COMMIT
                conn.commit();
                System.out.println("✓ TRANSAÇÃO CONCLUÍDA COM SUCESSO!");
                
                // Redirecionar
                response.sendRedirect("confirmacao.jsp?encomenda=" + idEncomenda + "&fatura=" + idFatura);
                return;
                
            } catch (Exception e) {
                if (conn != null) {
                    try {
                        conn.rollback();
                        System.out.println("✗ ROLLBACK executado");
                    } catch (SQLException ex) {
                        ex.printStackTrace();
                    }
                }
                
                String errorMsg = "Erro ao processar compra: " + e.getMessage();
                session.setAttribute("erro_checkout", errorMsg);
                e.printStackTrace();
                
                response.sendRedirect("pagamento.jsp");
                return;
                
            } finally {
                if (conn != null) {
                    try {
                        conn.setAutoCommit(true);
                        conn.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            }
            
        } catch (Exception e) {
            session.setAttribute("erro_checkout", "Erro geral: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("pagamento.jsp");
            return;
        }
    }
%>
</head>
<body>
    <div class="container">
        <a href="Produtos.jsp" class="btn-back">
            <i class="fas fa-arrow-left"></i>
            Voltar à Loja
        </a>
        
        <div class="page-header">
            <h1><i class="fas fa-shopping-cart"></i> Finalizar Compra</h1>
            <p>Preencha os dados para concluir o seu pedido</p>
        </div>
        
        <% 
            String erro = (String) session.getAttribute("erro_checkout");
            if (erro != null) {
        %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i>
                <%= erro %>
            </div>
        <%
                session.removeAttribute("erro_checkout");
            }
        %>
        
        <form method="post" action="pagamento.jsp" id="checkout-form">
            <div class="checkout-grid">
                <div>
                    <!-- Informações do Utilizador -->
                    <div class="checkout-section">
                        <h2 class="section-title">
                            <i class="fas fa-user"></i>
                            Informações do Cliente
                        </h2>
                        
                        <div class="form-group">
                            <label><i class="fas fa-user"></i> Nome:</label>
                            <div class="user-info"><%= nomeCompleto %></div>
                        </div>
                        
                        <div class="form-group">
                            <label><i class="fas fa-envelope"></i> Email:</label>
                            <div class="user-info"><%= emailUtilizador %></div>
                        </div>
                    </div>
                    
                    <!-- Morada de Envio -->
                    <div class="checkout-section" style="margin-top: 2rem;">
                        <h2 class="section-title">
                            <i class="fas fa-map-marker-alt"></i>
                            Morada de Envio
                        </h2>
                        
                        <div class="form-group">
                            <label for="morada_envio">
                                <i class="fas fa-home"></i>
                                Endereço Completo<span class="required">*</span>
                            </label>
                            <textarea 
                                name="morada_envio" 
                                id="morada_envio" 
                                class="form-control" 
                                placeholder="Rua, Número, Código Postal, Cidade"
                                required></textarea>
                        </div>
                    </div>
                    
                    <!-- Método de Pagamento -->
                    <div class="checkout-section" style="margin-top: 2rem;">
                        <h2 class="section-title">
                            <i class="fas fa-credit-card"></i>
                            Método de Pagamento
                        </h2>
                        
                        <div class="payment-methods">
                            <div class="payment-option">
                                <input type="radio" name="metodo_pagamento" id="multibanco" value="multibanco" required>
                                <label for="multibanco">
                                    <i class="fas fa-university"></i>
                                    <span>Multibanco</span>
                                </label>
                            </div>
                            
                            <div class="payment-option">
                                <input type="radio" name="metodo_pagamento" id="mbway" value="mbway">
                                <label for="mbway">
                                    <i class="fas fa-mobile-alt"></i>
                                    <span>MB WAY</span>
                                </label>
                            </div>
                            
                            <div class="payment-option">
                                <input type="radio" name="metodo_pagamento" id="cartao" value="cartao">
                                <label for="cartao">
                                    <i class="fas fa-credit-card"></i>
                                    <span>Cartão</span>
                                </label>
                            </div>
                            
                            <div class="payment-option">
                                <input type="radio" name="metodo_pagamento" id="paypal" value="paypal">
                                <label for="paypal">
                                    <i class="fab fa-paypal"></i>
                                    <span>PayPal</span>
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Resumo do Pedido -->
                <div>
                    <div class="checkout-section order-summary">
                        <h2 class="section-title">
                            <i class="fas fa-file-invoice"></i>
                            Resumo do Pedido
                        </h2>
                        
                        <div id="cart-summary"></div>
                        
                        <div class="summary-item">
                            <span>Subtotal:</span>
                            <span id="subtotal-display">0.00€</span>
                        </div>
                        
                        <div class="summary-item">
                            <span>IVA (23%):</span>
                            <span id="iva-display">0.00€</span>
                        </div>
                        
                        <div class="summary-item total">
                            <span>Total:</span>
                            <span id="total-display">0.00€</span>
                        </div>
                        
                        <input type="hidden" name="carrinho_json" id="carrinho_json">
                        
                        <button type="submit" class="btn-submit" id="btn-submit">
                            <i class="fas fa-check-circle"></i>
                            Confirmar Compra
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </div>
    
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        let carrinho = JSON.parse(localStorage.getItem('carrinho')) || [];
        
        console.log('=== CARRINHO CARREGADO ===');
        console.log('Itens:', carrinho);
        console.log('Número de itens:', carrinho.length);
        
        let subtotal = 0;
        let cartHTML = '';
        
        if (carrinho.length === 0) {
            console.warn('⚠️ CARRINHO VAZIO!');
            cartHTML = '<div class="alert alert-warning"><i class="fas fa-exclamation-triangle"></i> Carrinho vazio</div>';
            document.getElementById('btn-submit').disabled = true;
        } else {
            carrinho.forEach((item, index) => {
                console.log(`Processando item ${index + 1}:`, item);
                
                if (!item.preco || !item.quantidade) {
                    console.error('❌ Item inválido:', item);
                    return;
                }
                
                const totalItem = item.preco * item.quantidade;
                subtotal += totalItem;
                
                cartHTML += `
                    <div class="summary-item">
                        <span>${item.nome} x${item.quantidade}</span>
                        <span>${totalItem.toFixed(2)}€</span>
                    </div>
                `;
            });
            
            document.getElementById('btn-submit').disabled = false;
        }
        
        const iva = subtotal * 0.23;
        const total = subtotal + iva;
        
        console.log('Cálculos:');
        console.log('- Subtotal:', subtotal.toFixed(2));
        console.log('- IVA (23%):', iva.toFixed(2));
        console.log('- Total:', total.toFixed(2));
        
        document.getElementById('cart-summary').innerHTML = cartHTML;
        document.getElementById('subtotal-display').textContent = subtotal.toFixed(2) + '€';
        document.getElementById('iva-display').textContent = iva.toFixed(2) + '€';
        document.getElementById('total-display').textContent = total.toFixed(2) + '€';
        
        // ✅ ENVIAR TODO O CARRINHO EM JSON
        document.getElementById('carrinho_json').value = JSON.stringify(carrinho);
        
        console.log('JSON enviado:', document.getElementById('carrinho_json').value);
        console.log('=========================');
    });

    document.getElementById('checkout-form').addEventListener('submit', function(e) {
        const morada = document.getElementById('morada_envio').value.trim();
        const metodoPagamento = document.querySelector('input[name="metodo_pagamento"]:checked');
        const carrinho = JSON.parse(localStorage.getItem('carrinho')) || [];

        if (carrinho.length === 0) {
            e.preventDefault();
            alert('Carrinho vazio!');
            return;
        }

        if (!morada) {
            e.preventDefault();
            alert('Por favor, preencha a morada de envio.');
            return;
        }

        if (!metodoPagamento) {
            e.preventDefault();
            alert('Por favor, selecione um método de pagamento.');
            return;
        }

        if (!confirm('Deseja confirmar a compra no valor de ' + document.getElementById('total-display').textContent + '?')) {
            e.preventDefault();
            return;
        }
        localStorage.removeItem('carrinho');
        console.log('✅ Formulário validado, enviando...');
    });
    </script>
</body>
</html>