<%-- 
    Document   : InserirBilhetes
    Created on : Dec 23, 2025
    Author     : Francisco
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link href="style.css" rel="stylesheet" type="text/css">
        <%
        if (request.getMethod().equals("POST")) {  %>
            <meta http-equiv="refresh" content="2;url=admin.jsp">
        <% } %>
        <title>Inserção de Bilhetes</title>
    </head>
    <body>
        <h1>Inserir Bilhete</h1>
        <%
        if (request.getMethod().equals("POST")) {
            String id_evento = request.getParameter("id_evento");
            String id_utilizador = request.getParameter("id_utilizador");
            String nome_titular = request.getParameter("nome_titular");
            String email_titular = request.getParameter("email_titular");
            String telefone_titular = request.getParameter("telefone_titular");
            String tipo_bilhete = request.getParameter("tipo_bilhete");
            String setor = request.getParameter("setor");
            String fila = request.getParameter("fila");
            String lugar = request.getParameter("lugar");
            String preco_pago = request.getParameter("preco_pago");
            String estado_bilhete = request.getParameter("estado_bilhete");
            String metodo_pagamento = request.getParameter("metodo_pagamento");
            String observacoes = request.getParameter("observacoes");
            
            // Gerar código único para o bilhete
            String codigoBilhete = "SCRT" + System.currentTimeMillis();
            String numeroBilhete = "B" + String.format("%08d", (int)(Math.random() * 99999999));
            
            String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
            String username = "root";
            String password = "";
            
            try { 
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(url, username, password);
                
                String sql = "INSERT INTO t_bilhetes (id_evento, id_utilizador, codigo_bilhete, numero_bilhete, nome_titular, email_titular, telefone_titular, tipo_bilhete, setor, fila, lugar, preco_pago, estado_bilhete, data_reserva, data_venda, metodo_pagamento, observacoes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                
                statement.setInt(1, Integer.parseInt(id_evento));
                statement.setObject(2, id_utilizador.isEmpty() ? null : Integer.parseInt(id_utilizador));
                statement.setString(3, codigoBilhete);
                statement.setString(4, numeroBilhete);
                statement.setString(5, nome_titular);
                statement.setString(6, email_titular.isEmpty() ? null : email_titular);
                statement.setString(7, telefone_titular.isEmpty() ? null : telefone_titular);
                statement.setString(8, tipo_bilhete);
                statement.setString(9, setor);
                statement.setString(10, fila.isEmpty() ? null : fila);
                statement.setString(11, lugar.isEmpty() ? null : lugar);
                statement.setDouble(12, Double.parseDouble(preco_pago));
                statement.setString(13, estado_bilhete);
                statement.setObject(14, estado_bilhete.equals("vendido") ? new java.sql.Timestamp(System.currentTimeMillis()) : null);
                statement.setString(15, metodo_pagamento.isEmpty() ? null : metodo_pagamento);
                statement.setString(16, observacoes.isEmpty() ? null : observacoes);
                
                int rowsInserted = statement.executeUpdate();
                
                // Atualizar contador de bilhetes vendidos no evento
                if (rowsInserted > 0 && estado_bilhete.equals("vendido")) {
                    PreparedStatement updateEvento = conn.prepareStatement(
                        "UPDATE t_eventos SET bilhetes_vendidos = bilhetes_vendidos + 1 WHERE id_evento = ?"
                    );
                    updateEvento.setInt(1, Integer.parseInt(id_evento));
                    updateEvento.executeUpdate();
                    updateEvento.close();
                }
                
                if (rowsInserted > 0) {
                    out.println("<h2>Bilhete inserido com sucesso!</h2>");
                    out.println("<p><strong>Código do Bilhete:</strong> " + codigoBilhete + "</p>");
                    out.println("<p><strong>Número do Bilhete:</strong> " + numeroBilhete + "</p>");
                } else {
                    out.println("Erro na inserção.");
                }
                
                statement.close();
                conn.close();
                
            } catch (Exception e) {
                out.println("Ocorreu um erro: " + e.getMessage());
            }
        }
        else
        {
        %>
            <form method="post" action="InserirBilhetes.jsp">
                <label>Evento: 
                    <select name="id_evento" required id="eventoSelect" onchange="carregarPrecos()">
                        <option value="">Selecione o evento...</option>
                        <%
                            String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
                            String username = "root";
                            String password = "";
                            
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                Connection conn = DriverManager.getConnection(url, username, password);
                                Statement stmt = conn.createStatement();
                                ResultSet rs = stmt.executeQuery(
                                    "SELECT id_evento, nome_evento, data_evento, preco_normal, preco_socio, preco_estudante, preco_crianca " +
                                    "FROM t_eventos WHERE estado_evento IN ('agendado', 'venda_aberta') ORDER BY data_evento"
                                );
                                
                                while (rs.next()) {
                        %>
                                    <option value="<%= rs.getInt("id_evento") %>" 
                                            data-normal="<%= rs.getDouble("preco_normal") %>"
                                            data-socio="<%= rs.getDouble("preco_socio") %>"
                                            data-estudante="<%= rs.getDouble("preco_estudante") %>"
                                            data-crianca="<%= rs.getDouble("preco_crianca") %>">
                                        <%= rs.getString("nome_evento") %> - <%= rs.getTimestamp("data_evento") %>
                                    </option>
                        <%
                                }
                                rs.close();
                                stmt.close();
                                conn.close();
                            } catch (Exception e) {
                                out.println("<option value=''>Erro ao carregar eventos</option>");
                            }
                        %>
                    </select>
                </label><br/><br/>

                <label>Utilizador (opcional): 
                    <select name="id_utilizador">
                        <option value="">Sem utilizador registado</option>
                        <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                Connection conn = DriverManager.getConnection(url, username, password);
                                Statement stmt = conn.createStatement();
                                ResultSet rs = stmt.executeQuery(
                                    "SELECT id_utilizador, primeiro_nome, ultimo_nome, email FROM t_utilizadores ORDER BY primeiro_nome"
                                );
                                
                                while (rs.next()) {
                        %>
                                    <option value="<%= rs.getInt("id_utilizador") %>">
                                        <%= rs.getString("primeiro_nome") %> <%= rs.getString("ultimo_nome") %> (<%= rs.getString("email") %>)
                                    </option>
                        <%
                                }
                                rs.close();
                                stmt.close();
                                conn.close();
                            } catch (Exception e) {}
                        %>
                    </select>
                </label><br/><br/>

                <label>Nome do Titular: 
                    <input type="text" name="nome_titular" required placeholder="Nome completo" style="width: 300px;">
                </label><br/><br/>

                <label>Email do Titular: 
                    <input type="email" name="email_titular" placeholder="email@exemplo.com" style="width: 300px;">
                </label><br/><br/>

                <label>Telefone do Titular: 
                    <input type="text" name="telefone_titular" placeholder="912345678">
                </label><br/><br/>

                <label>Tipo de Bilhete: 
                    <select name="tipo_bilhete" required id="tipoBilhete" onchange="atualizarPreco()">
                        <option value="">Selecione...</option>
                        <option value="normal">Normal</option>
                        <option value="socio">Sócio</option>
                        <option value="estudante">Estudante</option>
                        <option value="crianca">Criança</option>
                    </select>
                </label><br/><br/>

                <label>Setor: 
                    <input type="text" name="setor" value="Geral" required>
                </label><br/><br/>

                <label>Fila (opcional): 
                    <input type="text" name="fila" placeholder="Ex: A">
                </label><br/><br/>

                <label>Lugar (opcional): 
                    <input type="text" name="lugar" placeholder="Ex: 15">
                </label><br/><br/>

                <label>Preço: 
                    <input type="number" step="0.01" name="preco_pago" id="precoPago" required>
                </label><br/><br/>

                <label>Estado: 
                    <select name="estado_bilhete" required>
                        <option value="reservado">Reservado</option>
                        <option value="vendido" selected>Vendido</option>
                        <option value="validado">Validado</option>
                        <option value="cancelado">Cancelado</option>
                    </select>
                </label><br/><br/>

                <label>Método de Pagamento: 
                    <select name="metodo_pagamento">
                        <option value="">Selecione...</option>
                        <option value="multibanco">Multibanco</option>
                        <option value="mbway">MBWay</option>
                        <option value="cartao">Cartão</option>
                        <option value="paypal">PayPal</option>
                        <option value="dinheiro">Dinheiro</option>
                    </select>
                </label><br/><br/>

                <label>Observações: 
                    <textarea name="observacoes" rows="4" cols="50" placeholder="Observações adicionais (opcional)"></textarea>
                </label><br/><br/>
                
                <input type="submit" value="Inserir Bilhete" class="bt">
            </form>

            <script>
                function atualizarPreco() {
                    var eventoSelect = document.getElementById('eventoSelect');
                    var tipoSelect = document.getElementById('tipoBilhete');
                    var precoInput = document.getElementById('precoPago');
                    
                    if (eventoSelect.value && tipoSelect.value) {
                        var opcaoSelecionada = eventoSelect.options[eventoSelect.selectedIndex];
                        var tipo = tipoSelect.value;
                        var preco = 0;
                        
                        switch(tipo) {
                            case 'normal':
                                preco = opcaoSelecionada.getAttribute('data-normal');
                                break;
                            case 'socio':
                                preco = opcaoSelecionada.getAttribute('data-socio');
                                break;
                            case 'estudante':
                                preco = opcaoSelecionada.getAttribute('data-estudante');
                                break;
                            case 'crianca':
                                preco = opcaoSelecionada.getAttribute('data-crianca');
                                break;
                        }
                        
                        precoInput.value = parseFloat(preco).toFixed(2);
                    }
                }
                
                function carregarPrecos() {
                    atualizarPreco();
                }
            </script>
        <%
        }
        %>
        <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
    </body>
</html>