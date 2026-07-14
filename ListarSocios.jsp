<%-- 
    Document   : ListarSocios
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
    <title>Listagem de Socios</title>
    <link href="style.css" rel="stylesheet" type="text/css">
</head>
<body>
    <h1>Listagem de Sócios</h1>
    
    <%
        int num = 0;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM t_socio");
    %>
    
    <table border="1">
        <tr>
            <th>Id</th>
            <th>Id_Utilizador</th>
            <th>Número de Sócio</th>
            <th>Telemóvel</th>
            <th>Cartão Cidadão</th>
            <th>Data Nascimento</th>
            <th>Quota Anual</th>
            <th>Data de Inscrição</th>
        </tr>
        <%
            while (rs.next()) {
                num++;
        %>
                <tr>
                    <td><%= rs.getInt("id_socio") %></td>
                    <td><%= rs.getInt("id_utilizador") %></td>
                    <td><%= rs.getString("numero_socio") %></td>
                    <td><%= rs.getString("telemovel") %></td>
                    <td><%= rs.getString("cartao_de_cidadao") %></td>
                    <td><%= rs.getDate("data_nascimento") %></td>
                    <td><%= rs.getBigDecimal("quota_anual") %></td>
                    <td><%= rs.getDate("data_inscricao") %></td>
                </tr>
        <%
            }
        %>
    </table>
    
    <p><b>Número total de registos na BD:</b> <%= num %></p>
    
    <%
            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            out.println("<p style='color:red;'>Ocorreu um erro: " + e.getMessage() + "</p>");
        }
    %>
    
    <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
 
</body>
</html>