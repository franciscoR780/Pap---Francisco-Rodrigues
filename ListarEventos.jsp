<%-- 
    Document   : ListarEventos
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
    <title>Listagem de Eventos</title>
    <link href="style.css" rel="stylesheet" type="text/css">
    <style>
        .badge {
            padding: 0.3rem 0.8rem;
            border-radius: 12px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-block;
        }
        .badge-agendado {
            background: #FFF3CD;
            color: #856404;
        }
        .badge-venda_aberta {
            background: #D1ECF1;
            color: #0C5460;
        }
        .badge-esgotado {
            background: #F8D7DA;
            color: #721C24;
        }
        .badge-concluido {
            background: #C3E6CB;
            color: #155724;
        }
        .badge-cancelado {
            background: #E2E3E5;
            color: #383D41;
        }
        table {
            font-size: 0.9rem;
        }
        td, th {
            padding: 8px;
        }
        .preco-box {
            background: #f8f9fa;
            padding: 5px;
            border-radius: 4px;
            font-size: 0.85rem;
        }
    </style>
</head>
<body>
    <h1>Listagem de Eventos</h1>
    <table border="1">
        <tr>
            <th>Id</th>
            <th>Nome do Evento</th>
            <th>Equipas</th>
            <th>Data do Evento</th>
            <th>Local</th>
            <th>Competição</th>
            <th>Preços</th>
            <th>Bilhetes</th>
            <th>Estado</th>
            <th>Data Criação</th>
        </tr>
        <%
            int num = 0;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(
                    "SELECT e.*, " +
                    "ec.nome_equipa AS equipa_casa, " +
                    "ef.nome_equipa AS equipa_fora " +
                    "FROM t_eventos e " +
                    "INNER JOIN t_equipas ec ON e.id_equipa_casa = ec.id_equipa " +
                    "LEFT JOIN t_equipas ef ON e.id_equipa_fora = ef.id_equipa " +
                    "ORDER BY e.data_evento DESC"
                );
                
                while (rs.next()) {
                    String estado = rs.getString("estado_evento");
                    String badgeClass = "badge-" + estado;
                    int vendidos = rs.getInt("bilhetes_vendidos");
                    int capacidade = rs.getInt("capacidade_total");
                    int disponiveis = capacidade - vendidos;
        %>
                    <tr>
                        <td><%= rs.getInt("id_evento") %></td>
                        <td>
                            <strong><%= rs.getString("nome_evento") %></strong><br/>
                            <small style="color: #666;">
                                <%= rs.getString("jornada") != null ? rs.getString("jornada") : "" %>
                            </small>
                        </td>
                        <td>
                            <%= rs.getString("equipa_casa") %><br/>
                            <small style="color: #666;">
                                vs <%= rs.getString("equipa_fora") != null ? rs.getString("equipa_fora") : "A definir" %>
                            </small>
                        </td>
                        <td><%= rs.getTimestamp("data_evento") %></td>
                        <td><%= rs.getString("local_evento") %></td>
                        <td><%= rs.getString("competicao") != null ? rs.getString("competicao") : "-" %></td>
                        <td class="preco-box">
                            <strong>Normal:</strong> <%= String.format("%.2f€", rs.getDouble("preco_normal")) %><br/>
                            <strong>Sócio:</strong> <%= String.format("%.2f€", rs.getDouble("preco_socio")) %><br/>
                            <strong>Estudante:</strong> <%= String.format("%.2f€", rs.getDouble("preco_estudante")) %><br/>
                            <strong>Criança:</strong> <%= String.format("%.2f€", rs.getDouble("preco_crianca")) %>
                        </td>
                        <td>
                            <strong><%= vendidos %></strong> / <%= capacidade %><br/>
                            <small style="color: <%= disponiveis > 0 ? "green" : "red" %>;">
                                <%= disponiveis %> disponíveis
                            </small>
                        </td>
                        <td>
                            <span class="badge <%= badgeClass %>">
                                <%= estado.toUpperCase() %>
                            </span>
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