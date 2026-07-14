<%--
    Document   : confirmacaoBilhete
    Created on : 04/12/2025, 19:55:21
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    String numeroVenda = request.getParameter("numero_venda");
    
    if (numeroVenda == null || numeroVenda.isEmpty()) {
        response.sendRedirect("Bilheteria.jsp");
        return;
    }
    
    // ATUALIZAR AUTOMATICAMENTE O ESTADO PARA "PAGO"
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection connUpdate = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
        
        PreparedStatement pstmtUpdate = connUpdate.prepareStatement(
            "UPDATE t_vendas_bilhetes SET estado_pagamento = 'pago' WHERE numero_venda = ? AND estado_pagamento = 'pendente'");
        pstmtUpdate.setString(1, numeroVenda);
        int rowsUpdated = pstmtUpdate.executeUpdate();
        
        if (rowsUpdated > 0) {
            out.println("<!-- Estado atualizado de 'pendente' para 'pago' com sucesso! -->");
        }
        
        pstmtUpdate.close();
        connUpdate.close();
    } catch (Exception e) {
        out.println("<!-- Erro ao atualizar estado: " + e.getMessage() + " -->");
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Confirmação de Compra</title>
    <link href="css/CssConfirmacaoBilhete.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>
<body>
    <div class="confirmacao-container">
        <div class="confirmacao-header">
            <div class="success-icon">
                <i class="fas fa-check-circle"></i>
            </div>
            <h1>Compra Realizada!</h1>
            <p>Os teus bilhetes foram reservados com sucesso</p>
        </div>

        <div class="confirmacao-body">
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                    
                    // Buscar informações da venda
                    PreparedStatement vendaStmt = conn.prepareStatement(
                        "SELECT v.*, CONCAT(u.primeiro_nome, ' ', u.ultimo_nome) as nome_utilizador " +
                        "FROM t_vendas_bilhetes v " +
                        "LEFT JOIN t_utilizadores u ON v.id_utilizador = u.id_utilizador " +
                        "WHERE v.numero_venda = ?");
                    vendaStmt.setString(1, numeroVenda);
                    ResultSet vendaRs = vendaStmt.executeQuery();
                    
                    if (vendaRs.next()) {
                        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy 'às' HH:mm");
                        
                        int quantidadeBilhetes = vendaRs.getInt("quantidade_bilhetes");
                        double valorTotal = vendaRs.getDouble("valor_total");
                        String metodoPagamento = vendaRs.getString("metodo_pagamento");
                        String estadoPagamento = vendaRs.getString("estado_pagamento");
                        Timestamp dataVenda = vendaRs.getTimestamp("data_venda");
                        String emailEnvio = vendaRs.getString("email_envio");
            %>
                        <div class="info-box">
                            <div class="info-item">
                                <span class="info-label">Número da Venda:</span>
                                <span class="info-value"><%= numeroVenda %></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Data da Compra:</span>
                                <span class="info-value"><%= sdf.format(dataVenda) %></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Quantidade de Bilhetes:</span>
                                <span class="info-value"><%= quantidadeBilhetes %></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Valor Total:</span>
                                <span class="info-value" style="color: var(--amarelo); font-size: 1.3rem;">
                                    <%= String.format("%.2f€", valorTotal) %>
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Método de Pagamento:</span>
                                <span class="info-value" style="text-transform: uppercase;">
                                    <%= metodoPagamento %>
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Estado:</span>
                                <span class="info-value" style="color: <%= "pago".equals(estadoPagamento) ? "var(--verde)" : "#FFA000" %>;">
                                    <%= estadoPagamento.toUpperCase() %>
                                </span>
                            </div>
                        </div>

                        <div class="pagamento-info">
                            <h4>
                                <i class="fas fa-check-circle"></i>
                                Pagamento Confirmado!
                            </h4>
                            <p>✅ O teu pagamento foi processado com sucesso!</p>
                            <p>📧 Enviámos um recibo detalhado para <strong><%= emailEnvio %></strong></p>
                            <p>🎫 Os teus bilhetes estão prontos! Podes imprimí-los abaixo.</p>
                            <p style="margin-top: 1rem;">
                                💡 <strong>Dica:</strong> Guarda este email e apresenta os bilhetes na entrada do estádio.
                            </p>
                        </div>

                        <div class="bilhetes-lista">
                            <h3>
                                <i class="fas fa-ticket-alt"></i>
                                Os Teus Bilhetes
                            </h3>
                            
                            <%
                                // Buscar bilhetes individuais
                                PreparedStatement bilhetesStmt = conn.prepareStatement(
                                    "SELECT b.*, e.nome_evento " +
                                    "FROM t_bilhetes b " +
                                    "INNER JOIN t_eventos e ON b.id_evento = e.id_evento " +
                                    "WHERE b.numero_bilhete LIKE ? " +
                                    "OR b.data_venda = ? " +
                                    "ORDER BY b.id_bilhete DESC " +
                                    "LIMIT ?");
                                bilhetesStmt.setString(1, "B%");
                                bilhetesStmt.setTimestamp(2, dataVenda);
                                bilhetesStmt.setInt(3, quantidadeBilhetes);
                                ResultSet bilhetesRs = bilhetesStmt.executeQuery();
                                
                                while (bilhetesRs.next()) {
                                    String codigoBilhete = bilhetesRs.getString("codigo_bilhete");
                                    String numeroBilhete = bilhetesRs.getString("numero_bilhete");
                                    String tipoBilhete = bilhetesRs.getString("tipo_bilhete");
                                    String nomeEvento = bilhetesRs.getString("nome_evento");
                                    String setor = bilhetesRs.getString("setor");
                                    double precoPago = bilhetesRs.getDouble("preco_pago");
                            %>
                                    <div class="bilhete-item">
                                        <div class="bilhete-header">
                                            <span class="bilhete-codigo"><%= codigoBilhete %></span>
                                            <span class="bilhete-tipo-badge"><%= tipoBilhete %></span>
                                        </div>
                                        <div class="bilhete-info-grid">
                                            <div class="bilhete-info-item">
                                                <strong>Evento:</strong> <%= nomeEvento %>
                                            </div>
                                            <div class="bilhete-info-item">
                                                <strong>Setor:</strong> <%= setor %>
                                            </div>
                                            <div class="bilhete-info-item">
                                                <strong>Número:</strong> <%= numeroBilhete %>
                                            </div>
                                            <div class="bilhete-info-item">
                                                <strong>Preço:</strong> <%= String.format("%.2f€", precoPago) %>
                                            </div>
                                        </div>
                                    </div>
                            <%
                                }
                                bilhetesRs.close();
                                bilhetesStmt.close();
                            %>
                        </div>

                        <div class="acoes-container">
                            <button class="btn-acao btn-primary" onclick="imprimirPDF()">
                                <i class="fas fa-print"></i>
                                Imprimir
                            </button>
                            <a href="Bilheteria.jsp" class="btn-acao btn-secondary">
                                <i class="fas fa-ticket-alt"></i>
                                Mais Eventos
                            </a>
                        </div>

                        <div class="rodape-info">
                            <p>💛 Obrigado por apoiar o SC Rio Tinto! 💛</p>
                            <p>
                                Qualquer dúvida, contacte-nos através de 
                                <strong>bilheteira@scriotinto.pt</strong>
                            </p>
                        </div>
            <%
                    } else {
                        out.println("<div style='text-align: center; padding: 3rem;'>");
                        out.println("<i class='fas fa-exclamation-triangle' style='font-size: 4rem; color: #EF4444; margin-bottom: 1rem;'></i>");
                        out.println("<h3>Venda não encontrada!</h3>");
                        out.println("<p style='color: #666; margin-top: 1rem;'>O número de venda " + numeroVenda + " não existe.</p>");
                        out.println("<a href='Bilheteria.jsp' class='btn-acao btn-primary' style='margin-top: 2rem; display: inline-flex;'>Voltar à Bilheteira</a>");
                        out.println("</div>");
                    }
                    
                    vendaRs.close();
                    vendaStmt.close();
                    conn.close();
                    
                } catch (Exception e) {
                    out.println("<div style='text-align: center; padding: 3rem;'>");
                    out.println("<i class='fas fa-times-circle' style='font-size: 4rem; color: #EF4444; margin-bottom: 1rem;'></i>");
                    out.println("<h3>Erro ao carregar informações</h3>");
                    out.println("<p style='color: #666;'>" + e.getMessage() + "</p>");
                    out.println("</div>");
                }
            %>
        </div>
    </div>

    <script>
        function imprimirPDF() {
            const resultado = confirm(
                '📄 INSTRUÇÕES PARA IMPRIMIR:\n\n' +
                '1. Nas configurações de impressão\n' +
                '2. DESATIVE "Cabeçalhos e rodapés"\n' +
                '3. Defina as margens como "Padrão" ou "Nenhuma"\n\n' +
                '4. Apenas Imprime a folha 2\n\n' +
                'Clique OK para continuar com a impressão.'
            );
            
            if (resultado) {
                window.print();
            }
        }

        function createConfetti() {
            const colors = ['#FFD700', '#FFA000', '#FFED4E'];
            const confettiCount = 50;
            
            for (let i = 0; i < confettiCount; i++) {
                const confetti = document.createElement('div');
                confetti.style.cssText = `
                    position: fixed;
                    width: 10px;
                    height: 10px;
                    background: ${colors[Math.floor(Math.random() * colors.length)]};
                    top: -10px;
                    left: ${Math.random() * 100}vw;
                    opacity: ${Math.random()};
                    animation: fall ${2 + Math.random() * 3}s linear;
                    pointer-events: none;
                `;
                document.body.appendChild(confetti);
                
                setTimeout(() => confetti.remove(), 5000);
            }
        }

        const style = document.createElement('style');
        style.textContent = `
            @keyframes fall {
                to {
                    transform: translateY(100vh) rotate(360deg);
                }
            }
        `;
        document.head.appendChild(style);

        window.addEventListener('load', () => {
            setTimeout(createConfetti, 300);
        });

        console.log('🎫 Bilhetes confirmados! Força Rio Tinto! 💛');
    </script>
</body>
</html>