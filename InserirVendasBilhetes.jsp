<%-- 
    Document   : InserirVendasBilhetes
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
        <title>Inserção de Vendas de Bilhetes</title>
    </head>
    <body>
        <h1>Inserir Venda de Bilhetes</h1>
        <%
        if (request.getMethod().equals("POST")) {
            String id_utilizador = request.getParameter("id_utilizador");
            String quantidade_bilhetes = request.getParameter("quantidade_bilhetes");
            String valor_total = request.getParameter("valor_total");
            String metodo_pagamento = request.getParameter("metodo_pagamento");
            String estado_pagamento = request.getParameter("estado_pagamento");
            String email_envio = request.getParameter("email_envio");
            String observacoes = request.getParameter("observacoes");
            
            // Gerar número de venda único
            String numeroVenda = "VB" + System.currentTimeMillis();
            
            String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
            String username = "root";
            String password = "";
            
            try { 
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(url, username, password);
                
                String sql = "INSERT INTO t_vendas_bilhetes (id_utilizador, numero_venda, data_venda, quantidade_bilhetes, valor_total, metodo_pagamento, estado_pagamento, email_envio, observacoes) VALUES (?, ?, NOW(), ?, ?, ?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                
                statement.setObject(1, id_utilizador.isEmpty() ? null : Integer.parseInt(id_utilizador));
                statement.setString(2, numeroVenda);
                statement.setInt(3, Integer.parseInt(quantidade_bilhetes));
                statement.setDouble(4, Double.parseDouble(valor_total));
                statement.setString(5, metodo_pagamento);
                statement.setString(6, estado_pagamento);
                statement.setString(7, email_envio.isEmpty() ? null : email_envio);
                statement.setString(8, observacoes.isEmpty() ? null : observacoes);
                
                int rowsInserted = statement.executeUpdate();
                if (rowsInserted > 0) {
                    out.println("<h2>Venda inserida com sucesso!</h2>");
                    out.println("<p><strong>Número da Venda:</strong> " + numeroVenda + "</p>");
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
            <form method="post" action="InserirVendasBilhetes.jsp">
                <label>Utilizador (opcional): 
                    <select name="id_utilizador">
                        <option value="">Sem utilizador registado</option>
                        <%
                            String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
                            String username = "root";
                            String password = "";
                            
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                Connection conn = DriverManager.getConnection(url, username, password);
                                Statement stmt = conn.createStatement();
                                ResultSet rs = stmt.executeQuery("SELECT id_utilizador, primeiro_nome, ultimo_nome, email FROM t_utilizadores ORDER BY primeiro_nome");
                                
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
                            } catch (Exception e) {
                                out.println("<option value=''>Erro ao carregar utilizadores</option>");
                            }
                        %>
                    </select>
                </label><br/><br/>

                <label>Quantidade de Bilhetes: 
                    <input type="number" name="quantidade_bilhetes" value="1" min="1" required>
                </label><br/><br/>

                <label>Valor Total: 
                    <input type="number" step="0.01" name="valor_total" required placeholder="0.00">
                </label><br/><br/>

                <label>Método Pagamento: 
                    <select name="metodo_pagamento" required>
                        <option value="">Selecione...</option>
                        <option value="multibanco">Multibanco</option>
                        <option value="mbway">MBWay</option>
                        <option value="cartao">Cartão</option>
                        <option value="paypal">PayPal</option>
                        <option value="dinheiro">Dinheiro</option>
                    </select>
                </label><br/><br/>

                <label>Estado do Pagamento: 
                    <select name="estado_pagamento" required>
                        <option value="pendente" selected>Pendente</option>
                        <option value="pago">Pago</option>
                        <option value="falhado">Falhado</option>
                        <option value="reembolsado">Reembolsado</option>
                    </select>
                </label><br/><br/>

                <label>Email para Envio: 
                    <input type="email" name="email_envio" placeholder="email@exemplo.com" style="width: 300px;">
                </label><br/><br/>

                <label>Observações: 
                    <textarea name="observacoes" rows="4" cols="50" placeholder="Observações adicionais (opcional)"></textarea>
                </label><br/><br/>
                
                <input type="submit" value="Inserir Venda" class="bt">
            </form>
        <%
        }
        %>
        <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
    </body>
</html>