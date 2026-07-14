<%-- 
    Document   : InserirFaturas
    Created on : Dec 15, 2025, 1:28:49 AM
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
        <title>Inserção de Faturas</title>
    </head>
    <body>
        <h1>Inserir Faturas</h1>
        <%
        if (request.getMethod().equals("POST")) {
            String id_utilizador = request.getParameter("id_utilizador");
            String id_encomenda = request.getParameter("id_encomenda");
            String data_emissao = request.getParameter("data_emissao");
            String data_pagamento = request.getParameter("data_pagamento");
            String metodo_pagamento = request.getParameter("metodo_pagamento");
            String valor_subtotal = request.getParameter("valor_subtotal");
            String valor_iva = request.getParameter("valor_iva");
            String valor_desconto = request.getParameter("valor_desconto");
            String observacoes = request.getParameter("observacoes");
            
            String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
            String username = "root";
            String password = "";
            
            try { 
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(url, username, password);
                
                String sql = "INSERT INTO t_fatura (id_utilizador, id_encomenda, data_emissao, data_pagamento, metodo_pagamento, valor_subtotal, valor_iva, valor_desconto, observacoes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                
                statement.setInt(1, Integer.parseInt(id_utilizador));
                
                if (id_encomenda != null && !id_encomenda.trim().isEmpty()) {
                    statement.setInt(2, Integer.parseInt(id_encomenda));
                } else {
                    statement.setNull(2, Types.INTEGER);
                }
                
                statement.setString(3, data_emissao);
                
                if (data_pagamento != null && !data_pagamento.trim().isEmpty()) {
                    statement.setString(4, data_pagamento);
                } else {
                    statement.setNull(4, Types.DATE);
                }
                
                statement.setString(5, metodo_pagamento);
                statement.setDouble(6, Double.parseDouble(valor_subtotal));
                statement.setDouble(7, Double.parseDouble(valor_iva));
                statement.setDouble(8, Double.parseDouble(valor_desconto));
                
                if (observacoes != null && !observacoes.trim().isEmpty()) {
                    statement.setString(9, observacoes);
                } else {
                    statement.setNull(9, Types.VARCHAR);
                }
                
                int rowsInserted = statement.executeUpdate();
                if (rowsInserted > 0) {
                    out.println("<h2>Registo inserido com sucesso.</h2>");
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
            <form method="post" action="InserirFaturas.jsp">
                <label>Utilizador: 
                    <select name="id_utilizador" required>
                        <option value="">Selecione o utilizador...</option>
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
                                    int idUser = rs.getInt("id_utilizador");
                                    String primeiroNome = rs.getString("primeiro_nome");
                                    String ultimoNome = rs.getString("ultimo_nome");
                                    String nomeCompleto = primeiroNome + " " + ultimoNome;
                                    String email = rs.getString("email");
                        %>
                                    <option value="<%= idUser %>"><%= nomeCompleto %> (<%= email %>)</option>
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
                
                <label>Id Encomenda: <input type="number" name="id_encomenda" 
                                        placeholder="ID da encomenda (opcional)"></label><br/><br/>
                
                <label>Data Emissão: <input type="date" name="data_emissao" required></label><br/><br/>
                
                <label>Data Pagamento: <input type="date" name="data_pagamento" 
                                        placeholder="Data de pagamento (opcional)"></label><br/><br/>
                
                <label>Método Pagamento: 
                    <select name="metodo_pagamento" required>
                        <option value="">Selecione...</option>
                        <option value="multibanco">Multibanco</option>
                        <option value="mbway">MBWay</option>
                        <option value="cartao">Cartão</option>
                        <option value="paypal">PayPal</option>
                    </select>
                </label><br/><br/>
                
                <label>Valor Subtotal: <input type="number" step="0.01" name="valor_subtotal" required 
                                        placeholder="0.00"></label><br/><br/>
                
                <label>Valor IVA: <input type="number" step="0.01" name="valor_iva" value="0.00" 
                                        placeholder="0.00"></label><br/><br/>
                
                <label>Valor Desconto: <input type="number" step="0.01" name="valor_desconto" value="0.00" 
                                        placeholder="0.00"></label><br/><br/>
                
                <label>Observações: <textarea name="observacoes" rows="4" cols="50" 
                                        placeholder="Observações (opcional)"></textarea></label><br/><br/>
                
                <input type="submit" value="Inserir" class="bt">
            </form>
        <%
        }
        %>
        <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
    </body>
</html>
