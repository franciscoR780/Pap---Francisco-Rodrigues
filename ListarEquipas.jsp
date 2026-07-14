<%-- 
    Document   : ListarEquipas
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
    <title>Listagem de Equipas</title>
    <link href="style.css" rel="stylesheet" type="text/css">
</head>
<body>
    <h1>Listagem de Equipas</h1>
    <table border="1">
        <tr>
            <th>Id Equipa</th>
            <th>Nome Equipa</th>
            <th>Categoria</th>
            <th>Temporada</th>
            <th>Data Criação</th>
        </tr>
        <%
            int num=0;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM t_equipas");
                
                while (rs.next()) {
        %>
                    <tr>
                        <td><%= rs.getInt("id_equipa") %></td>
                        <td><%= rs.getString("nome_equipa") %></td>
                        <td><%= rs.getString("categoria") %></td>
                        <td><%= rs.getString("temporada") %></td>
                        <td><%= rs.getDate("data_criacao") %></td>
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