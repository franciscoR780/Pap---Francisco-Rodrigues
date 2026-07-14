<%-- 
    Document   : InserirEquipas
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
        if (request.getMethod().equals("POST")) {  %>
            <meta http-equiv="refresh" content="2;url=index.jsp">
        <% } %>
        <title>Inserção de Equipas</title>
    </head>
    <body>
        <h1>Inserir Equipas</h1>
        <%
        if (request.getMethod().equals("POST")) {
            String nome_equipa = request.getParameter("nome_equipa");
            String categoria = request.getParameter("categoria");
            String temporada = request.getParameter("temporada");
            String data_criacao = request.getParameter("data_criacao");
            
            String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
            String username = "root";
            String password = "";
            
            try { 
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(url, username, password);
                
                String sql = "INSERT INTO t_equipas (nome_equipa, categoria, temporada, data_criacao) VALUES (?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                
                statement.setString(1, nome_equipa);
                statement.setString(2, categoria);
                statement.setString(3, temporada);
                statement.setString(4, data_criacao);
                
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
            <form method="post" action="InserirEquipas.jsp">
                <label>Nome Equipa: <input type="text" name="nome_equipa" size="20" 
                                        placeholder="Coloque o nome da equipa"></label><br/><br/>
                <label>Categoria: <input type="text" name="categoria" size="20" 
                                        placeholder="Coloque a categoria"></label><br/><br/>
                <label>Temporada: <input type="text" name="temporada" size="20" 
                                        placeholder="Coloque a temporada"></label><br/><br/>
                <label>Data Criação: <input type="date" name="data_criacao"></label><br/><br/>
                <input type="submit" value="Inserir" class="bt">
            </form>
        <%
        }
        %>
        <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
    </body>
</html>