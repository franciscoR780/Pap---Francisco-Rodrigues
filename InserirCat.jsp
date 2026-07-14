<%-- 
    Document   : InserirCat
    Created on : 11/11/2025, 11:24:04
    Author     : Aluno
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link href="style.css" rel="stylesheet" type="text/css">
        <%
        // verifica se houve um post
        if (request.getMethod().equals("POST")) {  %>
            <meta http-equiv="refresh" content="2;url=index.jsp">
        <% } %>
        <title>Inserção de Categorias</title>
    </head>
    <body>
        <h1>Inserir Categorias</h1>
        <%
        // verifica se houve um post
        if (request.getMethod().equals("POST")) {

            String nome = request.getParameter("nome");
            String descricao = request.getParameter("descricao");
            String ativo = request.getParameter("ativo");
            String imagem = request.getParameter("imagem");
            String ordem = request.getParameter("ordem");

            // JDBC parametros de conexão
            String url = "jdbc:mysql://localhost:3306/pap";
            String username = "root";
            String password = "";

            try { 
                // Load the MySQL JDBC driver
                Class.forName("com.mysql.jdbc.Driver");
                // Establish the connection
                Connection conn = DriverManager.getConnection(url, username, password);

                // Prepare the SQL statement for insertion
                String sql = "INSERT INTO t_categoria (nome, descricao, ativo, imagem, ordem) " +
                             "VALUES (?, ?, ?, ?, ?)";

                PreparedStatement statement = conn.prepareStatement(sql);

                // Substitui os ? pelos parametros correspondentes
                statement.setString(1, nome);
                statement.setString(2, descricao);
                statement.setInt(3, Integer.parseInt(ativo));
                statement.setString(4, imagem);
                statement.setInt(5, Integer.parseInt(ordem));

                // Executar a instrução SQL
                int rowsInserted = statement.executeUpdate();

                if (rowsInserted > 0) {
                    out.println("<h2>Registo inserido com sucesso.</h2>");
                } else {
                    out.println("Erro na inserção.");
                }

                // Close resources
                statement.close();
                conn.close();

            } catch (Exception e) {
                out.println("Ocorreu um erro: " + e.getMessage());
            }

        } else {
        %>

            <form method="post" action="InserirCat.jsp">

                <label>Categoria:
                    <input type="text" name="nome" size="20" placeholder="Coloque a categoria">
                </label><br/><br/>

                <label>Descrição:<br>
                    <textarea name="descricao" rows="4" cols="40"></textarea>
                </label><br/><br/>

                <label>Ativo:
                    <select name="ativo">
                        <option value="1">Sim</option>
                        <option value="0">Não</option>
                    </select>
                </label><br/><br/>

                <label>Imagem (URL):
                    <input type="text" name="imagem" size="40" placeholder="">
                </label><br/><br/>

                <label>Ordem:
                    <input type="number" name="ordem" value="0">
                </label><br/><br/>

                <input type="submit" value="Inserir" class="bt">
            </form>

        <%
        }
        %>

        <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
    </body>
</html>
