<%-- 
    Document   : ListarVendasBilhetes
    Created on : Dec 23, 2025
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Listagem de Vendas de Bilhetes</title>
    <link href="style.css" rel="stylesheet" type="text/css">
    <style>
        .badge {
            padding: 0.3rem 0.8rem;
            border-radius: 12px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-block;
        }
        .badge-pendente {
            background: #FFF3CD;
            color: #856404;
        }
        .badge-pago {
            background: #D4EDDA;
            color: #155724;
        }
        .badge-falhado {
            background: #F8D7DA;
            color: #721C24;
        }
        .badge-reembolsado {
            background: #E2E3E5;
            color: #383D41;
        }
        table {
            font-size: 0.9rem;
        }
        td, th {
            padding: 8px;
        }
    </style>
</head>
<body>
    <h1>Listagem de Vendas de Bilhetes</h1>
    <table border="1">
        <tr>
            <th>Id</th>
            <th>Nº Venda</th>
            <th>Utilizador</th>
            <th>Data Venda</th>
            <th>Quantidade</th>
            <th>Valor Total</th>
            <th>Método Pag.</th>
            <th>Estado</th>
            <th>Email Envio</th>
            <th>Observações</th>
            <th>Data Criação</th>
        </tr>
        <%
            int num = 0;
            double totalVendas = 0.0;
            int totalBilhetes = 0;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(
                    "SELECT v.*, " +
                    "CONCAT(u.primeiro_nome, ' ', u.ultimo_nome) as nome_utilizador, " +
                    "u.email as email_utilizador " +
                    "FROM t_vendas_bilhetes v " +
                    "LEFT JOIN t_utilizadores u ON v.id_utilizador = u.id_utilizador " +
                    "ORDER BY v.id_venda DESC"
                );
                
                while (rs.next()) {
                    String estado = rs.getString("estado_pagamento");
                    String badgeClass = "badge-" + estado;
                    String obs = rs.getString("observacoes");
                    double valor = rs.getDouble("valor_total");
                    int qtd = rs.getInt("quantidade_bilhetes");
                    
                    if (estado.equals("pago")) {
                        totalVendas += valor;
                        totalBilhetes += qtd;
                    }
        %>
                    <tr>
                        <td><%= rs.getInt("id_venda") %></td>
                        <td><strong><%= rs.getString("numero_venda") %></strong></td>
                        <td>
                            <% if (rs.getString("nome_utilizador") != null) { %>
                                <%= rs.getString("nome_utilizador") %><br/>
                                <small style="color: #666;"><%= rs.getString("email_utilizador") %></small>
                            <% } else { %>
                                <span style="color: #999;">Sem utilizador</span>
                            <% } %>
                        </td>
                        <td><%= rs.getTimestamp("data_venda") %></td>
                        <td><strong><%= qtd %></strong> bilhete(s)</td>
                        <td><strong><%= String.format("%.2f€", valor) %></strong></td>
                        <td><%= rs.getString("metodo_pagamento").toUpperCase() %></td>
                        <td>
                            <span class="badge <%= badgeClass %>">
                                <%= estado.toUpperCase() %>
                            </span>
                        </td>
                        <td><%= rs.getString("email_envio") != null ? rs.getString("email_envio") : "-" %></td>
                        <td><%= obs != null ? obs : "-" %></td>
                        <td><%= rs.getTimestamp("data_criacao") %></td>
                        <% num++; %>
                    </tr>
        <%
                }
        %>
    </table>
    
    <br/>
    
    <table border="1" style="background: #f8f9fa; max-width: 500px;">
        <tr>
            <th colspan="2" style="background: #007bff; color: white;">Resumo de Vendas</th>
        </tr>
        <tr>
            <th>Número de vendas registadas:</th>
            <td><strong><%= num %></strong></td>
        </tr>
        <tr>
            <th>Total de bilhetes vendidos (pagos):</th>
            <td><strong><%= totalBilhetes %></strong></td>
        </tr>
        <tr>
            <th>Valor total arrecadado (pagos):</th>
            <td><strong><%= String.format("%.2f€", totalVendas) %></strong></td>
        </tr>
    </table>
    
    <%
                rs.close();
                stmt.close();
                conn.close();
            } catch (Exception e) {
                out.println("Ocorreu um erro: " + e.getMessage());
            }
        %>
    
    <br/>
    <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
 
</body>
</html>