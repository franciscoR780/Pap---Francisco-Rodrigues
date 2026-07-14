<%-- 
    Document   : ListarEncomendas
    Created on : Dec 15, 2025, 1:52:19 AM
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Listagem de Encomendas</title>
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
        .badge-processando {
            background: #D1ECF1;
            color: #0C5460;
        }
        .badge-enviado {
            background: #D4EDDA;
            color: #155724;
        }
        .badge-entregue {
            background: #C3E6CB;
            color: #155724;
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
    <h1>Listagem de Encomendas</h1>
    <table border="1">
        <tr>
            <th>Id</th>
            <th>Nº Encomenda</th>
            <th>Utilizador</th>
            <th>Data Encomenda</th>
            <th>Última Atualização</th>
            <th>Morada Envio</th>
            <th>Método Pagamento</th>
            <th>Estado</th>
            <th>Código Rastreio</th>
            <th>Valor Total</th>
            <th>Desconto</th>
            <th>Taxa Envio</th>
            <th>Observações</th>
        </tr>
        <%
            int num = 0;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(
                    "SELECT e.*, " +
                    "CONCAT(u.primeiro_nome, ' ', u.ultimo_nome) as nome_utilizador, " +
                    "u.email " +
                    "FROM t_encomendas e " +
                    "INNER JOIN t_utilizadores u ON e.id_utilizador = u.id_utilizador " +
                    "ORDER BY e.id_encomenda DESC"
                );
                
                while (rs.next()) {
                    String estado = rs.getString("estado");
                    String badgeClass = "badge-" + estado;
                    String numeroEnc = rs.getString("numero_encomenda");
                    String codRastreio = rs.getString("codigo_rastreio");
                    String obs = rs.getString("observacoes");
        %>
                    <tr>
                        <td><%= rs.getInt("id_encomenda") %></td>
                        <td><%= numeroEnc != null ? numeroEnc : "-" %></td>
                        <td><%= rs.getString("nome_utilizador") %><br/>
                            <small style="color: #666;"><%= rs.getString("email") %></small>
                        </td>
                        <td><%= rs.getTimestamp("data_encomenda") %></td>
                        <td><%= rs.getTimestamp("data_atualizacao") %></td>
                        <td><%= rs.getString("morada_envio") %></td>
                        <td><%= rs.getString("metodo_pagamento") %></td>
                        <td>
                            <span class="badge <%= badgeClass %>">
                                <%= estado.toUpperCase() %>
                            </span>
                        </td>
                        <td><%= codRastreio != null ? codRastreio : "-" %></td>
                        <td><%= String.format("%.2f€", rs.getDouble("valor_total")) %></td>
                        <td><%= String.format("%.2f€", rs.getDouble("desconto")) %></td>
                        <td><%= String.format("%.2f€", rs.getDouble("taxa_envio")) %></td>
                        <td><%= obs != null ? obs : "-" %></td>
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