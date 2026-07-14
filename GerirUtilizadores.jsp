<%-- 
    Document   : GerirUtilizadores
    Created on : Dec 2, 2025, 8:09:24 PM
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" 
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gerir Utilizadores</title>
    <link href="style.css" rel="stylesheet" type="text/css">
<%
    if (request.getMethod().equals("POST")) {
        String acao = request.getParameter("acao");
        String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
        String username = "root";
        String password = "";
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, username, password);
            
            if (acao.equals("inserir")) {
                String primeiro_nome = request.getParameter("primeiro_nome");
                String ultimo_nome = request.getParameter("ultimo_nome");
                String email = request.getParameter("email");
                String telefone = request.getParameter("telefone");
                String tipo_utilizador = request.getParameter("tipo_utilizador");
                String palavra_passe = request.getParameter("palavra_passe");
                String data_nascimento = request.getParameter("data_nascimento");
                
                String sql = "INSERT INTO t_utilizadores (primeiro_nome, ultimo_nome, email, telefone, tipo_utilizador, palavra_passe, data_nascimento) VALUES (?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                statement.setString(1, primeiro_nome);
                statement.setString(2, ultimo_nome);
                statement.setString(3, email);
                statement.setString(4, telefone);
                statement.setString(5, tipo_utilizador);
                statement.setString(6, palavra_passe);
                statement.setString(7, data_nascimento);
                
                int rowsInserted = statement.executeUpdate();
                if (rowsInserted > 0) {
                    out.println("<h2>Registo inserido com sucesso.</h2>");
                } else {
                    out.println("Erro na inserção.");
                }
                statement.close();
            } 
            else { // apagar
                int id = Integer.parseInt(request.getParameter("id"));
                String sql = "DELETE FROM t_utilizadores WHERE id_utilizador=?";
                PreparedStatement stm = conn.prepareStatement(sql);
                stm.setInt(1, id);
                int rowsDeleted = stm.executeUpdate();
                if (rowsDeleted > 0) {
                    out.println("<h2>Registo apagado com sucesso</h2>");
                } else {
                    out.println("Não existe nenhum registo com esse id: " + id);
                }
                stm.close();
            }
            
            conn.close();
        } catch (Exception e) {
            out.println("Ocorreu um erro: " + e.getMessage());
        }
    }
%>
</head>

<body>
    <h1>Gerir Utilizadores</h1>
    
    <table border="1">
        <tr>
            <th>Id</th>
            <th>Primeiro Nome</th>
            <th>Último Nome</th>
            <th>Email</th>
            <th>Telefone</th>
            <th>Tipo</th>
            <th>Data Nascimento</th>
            <th>Data Criação</th>
            <th>Data Atualização</th>
        </tr>

<%
    int num = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
        Statement stmt = conn.createStatement();

        ResultSet rs = stmt.executeQuery("SELECT * FROM t_utilizadores");
        
        while (rs.next()) {
%>
            <tr>
                <td><%= rs.getInt("id_utilizador") %></td>
                <td><%= rs.getString("primeiro_nome") %></td>
                <td><%= rs.getString("ultimo_nome") %></td>
                <td><%= rs.getString("email") %></td>
                <td><%= rs.getString("telefone") %></td>
                <td><%= rs.getString("tipo_utilizador") %></td>
                <td><%= rs.getString("data_nascimento") %></td>
                <td><%= rs.getTimestamp("data_criacao") %></td>
                <td><%= rs.getTimestamp("data_atualizacao") %></td>
                <td>
                    <form method="post" action="GerirUtilizadores.jsp">
                        <input type="hidden" name="acao" value="apagar">
                        <input type="hidden" value="<%= rs.getInt("id_utilizador") %>" name="id">
                        <input type="submit" value="Apagar">
                    </form>
                </td>
            </tr>
<%
            num++;
        }
%>
    </table>

    <p><b>Número total de registos:</b> <%= num %></p>

<%
        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("Ocorreu um erro: " + e.getMessage());
    }
%>

    <h3>Inserir Utilizador</h3>
    
    <form method="post" action="GerirUtilizadores.jsp">
        <input type="hidden" name="acao" value="inserir">
        <label>Primeiro Nome: <input type="text" name="primeiro_nome"></label><br>
        <br>
        <label>Último Nome: <input type="text" name="ultimo_nome"></label><br>
        <br>
        <label>Email: <input type="email" name="email"></label><br>
        <br>
        <label>Telefone: <input type="text" name="telefone"></label><br>
        <br>
        <label>Tipo Utilizador: 
            <select name="tipo_utilizador">
<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn2 = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
        
        String sql = "SELECT COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='pap' AND TABLE_NAME='t_utilizadores' AND COLUMN_NAME='tipo_utilizador'";
        Statement stmt2 = conn2.createStatement();
        ResultSet rs2 = stmt2.executeQuery(sql);
        
        if (rs2.next()) {
            String columnType = rs2.getString("COLUMN_TYPE");
            String enumValues = columnType.substring(columnType.indexOf("(") + 1, columnType.indexOf(")"));
            String[] valores = enumValues.replace("'", "").split(",");
            
            for (String valor : valores) {
%>
                <option value="<%= valor %>"><%= valor %></option>
<%
            }
        }
        
        rs2.close();
        stmt2.close();
        conn2.close();
    } catch (Exception e) {
        out.println("Erro ao carregar tipos: " + e.getMessage());
    }
%>
            </select>
        </label><br>
        <label>Palavra-Passe: <input type="password" name="palavra_passe"></label><br>
        <label>Data Nascimento: <input type="date" name="data_nascimento"></label><br>
        <input type="submit" value="Inserir"><br><br>
    </form>

    <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
</body>
</html>