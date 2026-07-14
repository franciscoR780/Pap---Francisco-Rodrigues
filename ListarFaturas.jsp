<%-- 
    Document   : ListarFaturas
    Created on : Dec 15, 2025, 1:29:05 AM
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Listagem de Faturas</title>
    <link href="style.css" rel="stylesheet" type="text/css">
</head>
<body>
    <h1>Listagem de Faturas</h1>
    <table border="1">
        <tr>
            <th>Id Fatura</th>
            <th>Id Utilizador</th>
            <th>Id Encomenda</th>
            <th>Data Emissão</th>
            <th>Data Pagamento</th>
            <th>Método Pagamento</th>
            <th>Valor Subtotal</th>
            <th>Valor IVA</th>
            <th>Valor Desconto</th>
            <th>Observações</th>
        </tr>
        <%
            int num = 0;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM t_fatura");
                
                while (rs.next()) {
        %>
                    <tr>
                        <td><%= rs.getInt("id_fatura") %></td>
                        <td><%= rs.getInt("id_utilizador") %></td>
                        <td><%= rs.getObject("id_encomenda") != null ? rs.getInt("id_encomenda") : "N/A" %></td>
                        <td><%= rs.getDate("data_emissao") %></td>
                        <td><%= rs.getDate("data_pagamento") != null ? rs.getDate("data_pagamento") : "Pendente" %></td>
                        <td><%= rs.getString("metodo_pagamento") %></td>
                        <td><%= String.format("%.2f€", rs.getDouble("valor_subtotal")) %></td>
                        <td><%= String.format("%.2f€", rs.getDouble("valor_iva")) %></td>
                        <td><%= String.format("%.2f€", rs.getDouble("valor_desconto")) %></td>
                        <td><%= rs.getString("observacoes") != null ? rs.getString("observacoes") : "" %></td>
                        <% num++; %>
                    </tr>
        <%
                }
        %>
    </table>
    <tr><th>Número de registos na BD:</th>
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
    <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
 
</body>
</html>
