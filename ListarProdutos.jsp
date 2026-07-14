<%-- 
    Document   : ListarProdutos
    Created on : Dec 14, 2025, 4:02:34 PM
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Listagem de Produtos</title>
    <link href="style.css" rel="stylesheet" type="text/css">
</head>
<body>
    <h1>Listagem de Produtos</h1>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Categoria</th>
            <th>Nome</th>
            <th>Descrição</th>
            <th>Preço</th>
            <th>Stock</th>
            <th>Temporada</th>
            <th>Imagem</th>
            <th>Data Criação</th>
            <th>Data Atualização</th>
        </tr>
        <%
            int num=0;
            try {
                Class.forName("com.mysql.jdbc.Driver");
                //nome do server, user e pass
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
                Statement stmt = conn.createStatement();
                //executa a instrução na bd à qual criei a ligação
                ResultSet rs = stmt.executeQuery("SELECT * FROM t_produtos");
                
                while (rs.next()) {
        %>
                   <tr>
                    <td><%= rs.getInt("id_produto") %></td>
                    <td><%= rs.getInt("id_categoria") %></td>
                    <td><%= rs.getString("nome_produto") %></td>
                    <td><%= rs.getString("descricao") %></td>
                    <td><%= rs.getDouble("preco") %></td>
                    <td><%= rs.getInt("stock") %></td>
                    <td><%= rs.getString("temporada") %></td>
                    <td><%= rs.getString("imagem_principal") %></td>
                    <td><%= rs.getTimestamp("data_criacao") %></td>
                    <td><%= rs.getTimestamp("data_atualizacao") %></td>
                </tr>
                    <% num++; %>
        <%
                }
        %>
    </table>
    <tr><th>Número de registo na BD</th>
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
