<%-- 
    Document   : ListarUtilizadores
    Created on : 11/11/2025, 11:19:55
    Author     : Aluno
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Listagem de Utilizadores</title>
    <link href="style.css" rel="stylesheet" type="text/css">
</head>
<body>
    <h1>Listagem de Utilizadores</h1>
    <table border="1">
        <tr>
            <th>Id</th>
            <th>Primeiro Nome</th>
            <th>Último Nome</th>
            <th>Email</th>
            <th>Telefone</th>
            <th>Tipo</th>
            <th>Data Nascimento</th>
            <th>Data Criação</th>
            <th>Data Atualização</th>
        </tr>
        <%
            int num=0;
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM t_utilizadores");
                
                while (rs.next()) {
        %>
                    <tr>
                        <td><%= rs.getInt("id_utilizador") %></td>
                        <td><%= rs.getString("primeiro_nome") %></td>
                        <td><%= rs.getString("ultimo_nome") %></td>
                        <td><%= rs.getString("email") %></td>
                        <td><%= rs.getString("telefone") %></td>
                        <td><%= rs.getString("tipo_utilizador") %></td>
                        <td><%= rs.getString("data_nascimento") %></td>
                        <td><%= rs.getTimestamp("data_criacao") %></td>
                        <td><%= rs.getTimestamp("data_atualizacao") %></td>
                        <% num ++; %>
                    </tr>
        <%
                }
        %>
    </table>
    <tr><th >Número de registo na BD:</th>
    <th><%= num %></th></tr>
    <%
                rs.close();
                stmt.close();
                conn.close();
            } catch (Exception e) {
                out.println("Ocorreu um erro: " + e.getMessage());
            }
        %>
    
    </table>
    <a class = "bt" href="admin.jsp" target="_self">Voltar ao menu</a>
 
</body>
</html>