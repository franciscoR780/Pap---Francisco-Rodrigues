<%-- 
    Document   : ListarItensEncomenda
    Created on : Dec 15, 2025, 1:59:55 PM
    Author     : Francisco
--%>


<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Listagem de Itens de Encomenda</title>
    <link href="style.css" rel="stylesheet" type="text/css">
    <style>
        .group-header {
            background: #FFD700;
            font-weight: bold;
            color: #0a0a0a;
        }
        .item-row {
            background: #f9f9f9;
        }
        .total-row {
            background: #e8f5e9;
            font-weight: bold;
        }
        .summary-table {
            width: auto;
            margin-left: auto;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <h1>Listagem de Itens de Encomenda</h1>
    <table border="1">
        <tr>
            <th>ID Item</th>
            <th>ID Encomenda</th>
            <th>Utilizador</th>
            <th>Produto</th>
            <th>Quantidade</th>
            <th>Preço Unitário</th>
            <th>Preço Total</th>
        </tr>
        <%
            int num = 0;
            double totalGeral = 0.0;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(
                    "SELECT t_itens_encomenda.id_item, t_itens_encomenda.id_encomenda, " +
                    "t_itens_encomenda.id_produto, t_itens_encomenda.quantidade, t_itens_encomenda.preco_unitario, t_itens_encomenda.preco_total, " +
                    "CONCAT(t_utilizadores.primeiro_nome, ' ', t_utilizadores.ultimo_nome) as nome_utilizador, " +
                    "t_produtos.nome_produto, " +
                    "t_encomendas.data_encomenda, t_encomendas.estado " +
                    "FROM t_itens_encomenda " +
                    "INNER JOIN t_encomendas ON t_itens_encomenda.id_encomenda = t_encomendas.id_encomenda " +
                    "INNER JOIN t_utilizadores ON t_encomendas.id_utilizador = t_utilizadores.id_utilizador " +
                    "LEFT JOIN t_produtos ON t_itens_encomenda.id_produto = t_produtos.id_produto " +
                    "ORDER BY t_itens_encomenda.id_encomenda DESC, t_itens_encomenda.id_item DESC"
                );
                
                int currentEncomenda = -1;
                double subtotalEncomenda = 0.0;
                
                while (rs.next()) {
                    int idEncomenda = rs.getInt("id_encomenda");
                    
                    // Se mudou de encomenda, mostrar subtotal da anterior
                    if (currentEncomenda != -1 && currentEncomenda != idEncomenda) {
        %>
                        <tr class="total-row">
                            <td colspan="6" align="right"><strong>Subtotal Encomenda #<%= currentEncomenda %>:</strong></td>
                            <td><strong><%= String.format("%.2f€", subtotalEncomenda) %></strong></td>
                        </tr>
        <%
                        subtotalEncomenda = 0.0;
                    }
                    
                    // Cabeçalho da nova encomenda
                    if (currentEncomenda != idEncomenda) {
        %>
                        <tr class="group-header">
                            <td colspan="7">
                                <strong>Encomenda #<%= idEncomenda %></strong> - 
                                <%= rs.getString("nome_utilizador") %> - 
                                <%= rs.getString("data_encomenda") %> - 
                                Estado: <%= rs.getString("estado").toUpperCase() %>
                            </td>
                        </tr>
        <%
                        currentEncomenda = idEncomenda;
                    }
                    
                    double precoTotal = rs.getDouble("preco_total");
                    subtotalEncomenda += precoTotal;
                    totalGeral += precoTotal;
        %>
                    <tr class="item-row">
                        <td><%= rs.getInt("id_item") %></td>
                        <td><%= idEncomenda %></td>
                        <td><%= rs.getString("nome_utilizador") %></td>
                        <td><%= rs.getString("nome_produto") != null ? rs.getString("nome_produto") : "N/A" %></td>
                        <td><%= rs.getInt("quantidade") %></td>
                        <td><%= String.format("%.2f€", rs.getDouble("preco_unitario")) %></td>
                        <td><%= String.format("%.2f€", precoTotal) %></td>
                    </tr>
        <%
                    num++;
                }
                
                // Mostrar subtotal da última encomenda
                if (currentEncomenda != -1) {
        %>
                    <tr class="total-row">
                        <td colspan="6" align="right"><strong>Subtotal Encomenda #<%= currentEncomenda %>:</strong></td>
                        <td><strong><%= String.format("%.2f€", subtotalEncomenda) %></strong></td>
                    </tr>
        <%
                }
        %>
    </table>
    
    <table border="1" class="summary-table">
        <tr>
            <th>Número de itens na BD:</th>
            <th><%= num %></th>
        </tr>
        <tr>
            <th>Total Geral:</th>
            <th><%= String.format("%.2f€", totalGeral) %></th>
        </tr>
    </table>
    <%
                rs.close();
                stmt.close();
                conn.close();
            } catch (Exception e) {
                out.println("<div style='color: red; padding: 10px; background: #ffebee; margin: 10px 0;'>✗ Ocorreu um erro: " + e.getMessage() + "</div>");
            }
        %>
    
    <br>
    <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
 
</body>
</html>