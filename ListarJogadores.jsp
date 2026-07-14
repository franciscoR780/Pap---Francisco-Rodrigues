<%-- 
    Document   : ListarJogadores
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
    <title>Listagem de Jogadores</title>
    <link href="style.css" rel="stylesheet" type="text/css">
</head>
<body>
    <h1>Listagem de Jogadores</h1>
    <table border="1">
        <tr>
            <th>Id Jogador</th>
            <th>Id Equipa</th>
            <th>Primeiro Nome</th>
            <th>Último Nome</th>
            <th>Número Camisola</th>
            <th>Posição</th>
            <th>Foto</th>
        </tr>
        <%
            int num=0;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM t_jogadores");
                
                while (rs.next()) {
        %>
                    <tr>
                        <td><%= rs.getInt("id_jogador") %></td>
                        <td><%= rs.getInt("id_equipa") %></td>
                        <td><%= rs.getString("primeiro_nome") %></td>
                        <td><%= rs.getString("ultimo_nome") %></td>
                        <td><%= rs.getInt("numero_camisola") %></td>
                        <td><%= rs.getString("posicao") %></td>
                        <td><%= rs.getString("foto_url") %></td>
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
