<%-- 
    Document   : ListarBilhetes
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
    <title>Listagem de Bilhetes</title>
    <link href="style.css" rel="stylesheet" type="text/css">
    <style>
        .badge {
            padding: 0.3rem 0.8rem;
            border-radius: 12px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-block;
        }
        .badge-reservado {
            background: #FFF3CD;
            color: #856404;
        }
        .badge-vendido {
            background: #D1ECF1;
            color: #0C5460;
        }
        .badge-validado {
            background: #D4EDDA;
            color: #155724;
        }
        .badge-cancelado {
            background: #F8D7DA;
            color: #721C24;
        }
        .tipo-normal {
            color: #007bff;
            font-weight: bold;
        }
        .tipo-socio {
            color: #28a745;
            font-weight: bold;
        }
        .tipo-estudante {
            color: #17a2b8;
            font-weight: bold;
        }
        .tipo-crianca {
            color: #ffc107;
            font-weight: bold;
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
    <h1>Listagem de Bilhetes</h1>
    <table border="1">
        <tr>
            <th>Id</th>
            <th>Código</th>
            <th>Evento</th>
            <th>Titular</th>
            <th>Tipo</th>
            <th>Setor/Lugar</th>
            <th>Preço</th>
            <th>Estado</th>
            <th>Pagamento</th>
            <th>Data Criação</th>
        </tr>
        <%
            int num = 0;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(
                    "SELECT b.*, " +
                    "e.nome_evento, " +
                    "e.data_evento, " +
                    "CONCAT(u.primeiro_nome, ' ', u.ultimo_nome) as nome_utilizador " +
                    "FROM t_bilhetes b " +
                    "INNER JOIN t_eventos e ON b.id_evento = e.id_evento " +
                    "LEFT JOIN t_utilizadores u ON b.id_utilizador = u.id_utilizador " +
                    "ORDER BY b.id_bilhete DESC"
                );
                
                while (rs.next()) {
                    String estado = rs.getString("estado_bilhete");
                    String badgeClass = "badge-" + estado;
                    String tipo = rs.getString("tipo_bilhete");
                    String tipoClass = "tipo-" + tipo;
                    String fila = rs.getString("fila");
                    String lugar = rs.getString("lugar");
        %>
                    <tr>
                        <td><%= rs.getInt("id_bilhete") %></td>
                        <td>
                            <strong><%= rs.getString("codigo_bilhete") %></strong><br/>
                            <small style="color: #666;"><%= rs.getString("numero_bilhete") %></small>
                        </td>
                        <td>
                            <strong><%= rs.getString("nome_evento") %></strong><br/>
                            <small style="color: #666;"><%= rs.getTimestamp("data_evento") %></small>
                        </td>
                        <td>
                            <%= rs.getString("nome_titular") %><br/>
                            <small style="color: #666;">
                                <%= rs.getString("email_titular") != null ? rs.getString("email_titular") : "" %><br/>
                                <%= rs.getString("telefone_titular") != null ? rs.getString("telefone_titular") : "" %>
                            </small>
                            <% if (rs.getString("nome_utilizador") != null) { %>
                                <br/><small style="color: #28a745;"><strong>User:</strong> <%= rs.getString("nome_utilizador") %></small>
                            <% } %>
                        </td>
                        <td>
                            <span class="<%= tipoClass %>">
                                <%= tipo.toUpperCase() %>
                            </span>
                        </td>
                        <td>
                            <%= rs.getString("setor") %><br/>
                            <% if (fila != null && lugar != null) { %>
                                <small style="color: #666;">Fila <%= fila %> - Lugar <%= lugar %></small>
                            <% } else { %>
                                <small style="color: #999;">Lugar Livre</small>
                            <% } %>
                        </td>
                        <td><%= String.format("%.2f€", rs.getDouble("preco_pago")) %></td>
                        <td>
                            <span class="badge <%= badgeClass %>">
                                <%= estado.toUpperCase() %>
                            </span>
                        </td>
                        <td>
                            <%= rs.getString("metodo_pagamento") != null ? rs.getString("metodo_pagamento").toUpperCase() : "-" %>
                        </td>
                        <td><%= rs.getTimestamp("data_criacao") %></td>
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