<%-- 
    Document   : ListarNoticias
    Created on : Dec 28, 2025, 12:25:42 AM
    Author     : Francisco
--%>


<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Listagem de Notícias de Formação</title>
    <link href="style.css" rel="stylesheet" type="text/css">
    <style>
        .badge {
            padding: 0.3rem 0.8rem;
            border-radius: 12px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-block;
        }
        .badge-sub11 {
            background: #D1E7FF;
            color: #004085;
        }
        .badge-sub13 {
            background: #D4EDDA;
            color: #155724;
        }
        .badge-sub15 {
            background: #FFF3CD;
            color: #856404;
        }
        .badge-sub17 {
            background: #F8D7DA;
            color: #721C24;
        }
        .badge-sub19 {
            background: #E7D4F5;
            color: #5A189A;
        }
        .badge-geral {
            background: #E2E3E5;
            color: #383D41;
        }
        .badge-destaque {
            background: linear-gradient(135deg, #FFD700 0%, #FFA000 100%);
            color: #000;
            font-weight: 700;
            box-shadow: 0 2px 10px rgba(255, 215, 0, 0.3);
        }
        .badge-ativo {
            background: #D4EDDA;
            color: #155724;
        }
        .badge-inativo {
            background: #F8D7DA;
            color: #721C24;
        }
        table {
            font-size: 0.9rem;
        }
        td, th {
            padding: 8px;
        }
        .resumo-cell {
            max-width: 300px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
    </style>
</head>
<body>
    <h1>Listagem de Notícias de Formação</h1>
    <table border="1">
        <tr>
            <th>Id</th>
            <th>Título</th>
            <th>Categoria</th>
            <th>Resumo</th>
            <th>Ícone</th>
            <th>Status</th>
            <th>Visualizações</th>
            <th>Autor</th>
            <th>Data Publicação</th>
            <th>Data Criação</th>
        </tr>
        <%
            int num = 0;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(
                    "SELECT * FROM t_noticias_formacao ORDER BY id_noticia DESC"
                );
                
                while (rs.next()) {
                    String categoria = rs.getString("categoria");
                    String badgeClass = "badge-" + categoria;
                    boolean destaque = rs.getBoolean("destaque");
                    boolean ativo = rs.getBoolean("ativo");
        %>
                    <tr>
                        <td><%= rs.getInt("id_noticia") %></td>
                        <td>
                            <strong><%= rs.getString("titulo") %></strong>
                            <% if (destaque) { %>
                                <br/><span class="badge badge-destaque">⭐ DESTAQUE</span>
                            <% } %>
                        </td>
                        <td>
                            <span class="badge <%= badgeClass %>">
                                <%= categoria.toUpperCase() %>
                            </span>
                        </td>
                        <td class="resumo-cell">
                            <%= rs.getString("resumo") != null ? rs.getString("resumo") : "-" %>
                        </td>
                        <td>
                            <i class="<%= rs.getString("icone") %>" style="font-size: 1.5rem; color: #FFD700;"></i>
                        </td>
                        <td>
                            <span class="badge <%= ativo ? "badge-ativo" : "badge-inativo" %>">
                                <%= ativo ? "ATIVO" : "INATIVO" %>
                            </span>
                        </td>
                        <td style="text-align: center;"><%= rs.getInt("visualizacoes") %></td>
                        <td><%= rs.getString("autor") != null ? rs.getString("autor") : "-" %></td>
                        <td><%= rs.getTimestamp("data_publicacao") %></td>
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