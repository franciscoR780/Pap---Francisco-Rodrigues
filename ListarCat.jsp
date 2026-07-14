<%-- 
    Document   : ListarCat
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
    <title>Listagem</title>
    <link href="style.css" rel="stylesheet" type="text/css">
</head>
<body>
    <h1>Listagem de Categorias</h1>
    <table border="1">
        <tr>
            <th>id</th>
            <th>nome</th>
            <th>descricao</th>
            <th>ativo</th>
            <th>imagem</th>
            <th>ordem</th>
            <th>data_criacao</th>
            <th>data_atualizacao</th>
        </tr>
        <%
            int num=0;
            try {
                Class.forName("com.mysql.jdbc.Driver");
                //nome do server, user e pass
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
                Statement stmt = conn.createStatement();
                //executa a instrução na bd à qual criei a ligação
                ResultSet rs = stmt.executeQuery("SELECT * FROM t_categoria");
                
                while (rs.next()) {
        %>
                   <tr>
                    <td><%= rs.getInt("id_categoria") %></td>
                    <td><%= rs.getString("nome") %></td>
                    <td><%= rs.getString("descricao") %></td>
                    <td><%= rs.getInt("ativo") %></td>
                    <td><%= rs.getString("imagem") %></td>
                    <td><%= rs.getInt("ordem") %></td>
                    <td><%= rs.getTimestamp("data_criacao") %></td>
                    <td><%= rs.getTimestamp("data_atualizacao") %></td>
                </tr>
                    <% num++; %>

        <%
                }
        %>
    </table>
    <tr><th >Número de registo na BD</th>
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
