<%-- 
    Document   : InserirEncomenda
    Created on : Dec 15, 2025, 1:52:01 AM
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
        <title>Inserção de Encomendas</title>
    </head>
    <body>
        <h1>Inserir Encomendas</h1>
        <%
        if (request.getMethod().equals("POST")) {
            String id_utilizador = request.getParameter("id_utilizador");
            String morada_envio = request.getParameter("morada_envio");
            String metodo_pagamento = request.getParameter("metodo_pagamento");
            String estado = request.getParameter("estado");
            String valor_total = request.getParameter("valor_total");
            String numero_encomenda = request.getParameter("numero_encomenda");
            String codigo_rastreio = request.getParameter("codigo_rastreio");
            String observacoes = request.getParameter("observacoes");
            String desconto = request.getParameter("desconto");
            String taxa_envio = request.getParameter("taxa_envio");
            
            String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
            String username = "root";
            String password = "";
            
            try { 
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(url, username, password);
                
                String sql = "INSERT INTO t_encomendas (id_utilizador, morada_envio, metodo_pagamento, estado, valor_total, numero_encomenda, codigo_rastreio, observacoes, desconto, taxa_envio) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                
                statement.setInt(1, Integer.parseInt(id_utilizador));
                statement.setString(2, morada_envio);
                statement.setString(3, metodo_pagamento);
                statement.setString(4, estado);
                statement.setDouble(5, Double.parseDouble(valor_total));
                statement.setString(6, numero_encomenda.isEmpty() ? null : numero_encomenda);
                statement.setString(7, codigo_rastreio.isEmpty() ? null : codigo_rastreio);
                statement.setString(8, observacoes.isEmpty() ? null : observacoes);
                statement.setDouble(9, desconto.isEmpty() ? 0.0 : Double.parseDouble(desconto));
                statement.setDouble(10, taxa_envio.isEmpty() ? 0.0 : Double.parseDouble(taxa_envio));
                
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
            <form method="post" action="InserirEncomendas.jsp">
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
                
                <label>Número da Encomenda: 
                    <input type="text" name="numero_encomenda" placeholder="Ex: ENC2025001">
                </label><br/><br/>
                
                <label>Morada de Envio: 
                    <textarea name="morada_envio" rows="4" cols="50" required 
                              placeholder="Rua, Número, Código Postal, Cidade"></textarea>
                </label><br/><br/>
                
                <label>Método Pagamento: 
                    <select name="metodo_pagamento" required>
                        <option value="">Selecione...</option>
                        <option value="multibanco">Multibanco</option>
                        <option value="mbway">MBWay</option>
                        <option value="cartao">Cartão</option>
                        <option value="paypal">PayPal</option>
                    </select>
                </label><br/><br/>
                
                <label>Estado: 
                    <select name="estado" required>
                        <option value="pendente" selected>Pendente</option>
                        <option value="processando">Processando</option>
                        <option value="enviado">Enviado</option>
                        <option value="entregue">Entregue</option>
                    </select>
                </label><br/><br/>
                
                <label>Código de Rastreio: 
                    <input type="text" name="codigo_rastreio" placeholder="Ex: PT123456789BR">
                </label><br/><br/>
                
                <label>Valor Total: 
                    <input type="number" step="0.01" name="valor_total" required placeholder="0.00">
                </label><br/><br/>
                
                <label>Desconto: 
                    <input type="number" step="0.01" name="desconto" value="0.00" placeholder="0.00">
                </label><br/><br/>
                
                <label>Taxa de Envio: 
                    <input type="number" step="0.01" name="taxa_envio" value="0.00" placeholder="0.00">
                </label><br/><br/>
                
                <label>Observações: 
                    <textarea name="observacoes" rows="4" cols="50" 
                              placeholder="Observações adicionais (opcional)"></textarea>
                </label><br/><br/>
                
                <input type="submit" value="Inserir" class="bt">
            </form>
        <%
        }
        %>
        <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
    </body>
</html>