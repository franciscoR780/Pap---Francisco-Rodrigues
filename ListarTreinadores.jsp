<%-- 
    Document   : ListarTreinadores
    Created on : Dec 14, 2025, 1:26:01 PM
    Author     : Francisco
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Listagem de Treinadores</title>
    <link href="style.css" rel="stylesheet" type="text/css">
</head>
<body>
    <h1>Listagem de Treinadores</h1>
    <table border="1">
        <tr>
            <th>Id</th>
            <th>Nome Completo</th>
            <th>Equipa</th>
            <th>Nível</th>
            <th>Telefone</th>
            <th>Email</th>
            <th>Salário</th>
            <th>Ativo</th>
            <th>Foto</th>
            <th>Data Contratação</th>
        </tr>
        <%
            int num=0;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                Statement stmt = conn.createStatement();
                
                // Query com JOIN para mostrar nome da equipa
                ResultSet rs = stmt.executeQuery(
                    "SELECT t.*, e.nome_equipa " +
                    "FROM t_treinadores t " +
                    "LEFT JOIN t_equipas e ON t.id_equipa = e.id_equipa"
                );
                
                while (rs.next()) {
                    String nomeCompleto = rs.getString("primeiro_nome") + " " + rs.getString("ultimo_nome");
                    String nomeEquipa = rs.getString("nome_equipa");
                    if (nomeEquipa == null) nomeEquipa = "Sem equipa";
                    
                    String corAtivo = "";
                    int ativo = rs.getInt("ativo");
                    if (ativo == 1) {
                        corAtivo = "style='background-color: #90EE90;'"; // Verde
                    } else {
                        corAtivo = "style='background-color: #FFB6C1;'"; // Rosa
                    }
                    
                    java.math.BigDecimal salarioBD = rs.getBigDecimal("salario");
                    String salarioStr = (salarioBD != null) ? salarioBD.toString() : "0.00";
                    
                    Date dataContratacao = rs.getDate("data_contratacao");
                    String dataContratacaoStr = (dataContratacao != null) ? dataContratacao.toString() : "-";
        %>
                    <tr>
                        <td><%= rs.getInt("id_treinador") %></td>
                        <td><%= nomeCompleto %></td>
                        <td><%= nomeEquipa %></td>
                        <td><%= rs.getString("nivel_treinador") %></td>
                        <td><%= rs.getString("telefone") != null ? rs.getString("telefone") : "-" %></td>
                        <td><%= rs.getString("email") != null ? rs.getString("email") : "-" %></td>
                        <td><%= salarioStr %>€</td>
                        <td <%= corAtivo %>><%= ativo == 1 ? "Sim" : "Não" %></td>
                        <td><%= rs.getString("foto_url") %></td>
                        <td><%= dataContratacaoStr %></td>
                        <% num ++; %>
                    </tr>
        <%
                }
        %>
    </table>
    <table>
        <tr>
            <th>Número de registos na BD:</th>
            <th><%= num %></th>
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
    
    <a class = "bt" href="admin.jsp" target="_self">Voltar ao menu</a>
 
</body>
</html>