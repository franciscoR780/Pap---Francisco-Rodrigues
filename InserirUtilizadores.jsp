<%-- 
    Document   : InserirUtilizadores
    Created on : 11/11/2025, 11:24:04
    Author     : Aluno
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link href="style.css" rel="stylesheet" type="text/css">
        <%
        if (request.getMethod().equals("POST")) {  %>
            <meta http-equiv="refresh" content="2;url=index.jsp">
        <% } %>
        <title>Inserção de Utilizadores</title>
    </head>
    <body>
        <h1>Inserir Utilizadores</h1>
        <%
        if (request.getMethod().equals("POST")) {
            String primeiro_nome = request.getParameter("primeiro_nome");
            String ultimo_nome = request.getParameter("ultimo_nome");
            String email = request.getParameter("email");
            String telefone = request.getParameter("telefone");
            String tipo_utilizador = request.getParameter("tipo_utilizador");
            String palavra_passe = request.getParameter("palavra_passe");
            String data_nascimento = request.getParameter("data_nascimento");
            
            String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
            String username = "root";
            String password = "";
            
            try { 
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(url, username, password);
                
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
                conn.close();
                
            } catch (Exception e) {
                out.println("Ocorreu um erro: " + e.getMessage());
            }
        }
        else
        {
        %>
            <form method="post" action="InserirUtilizadores.jsp">
                <label>Primeiro Nome: <input type="text" name="primeiro_nome" size="20" 
                                        placeholder="Coloque o primeiro nome"></label><br/><br/>
                <label>Último Nome: <input type="text" name="ultimo_nome" size="20" 
                                        placeholder="Coloque o último nome"></label><br/><br/>
                <label>Email: <input type="email" name="email" size="20" 
                                        placeholder="Coloque o email"></label><br/><br/>
                <label>Telefone: <input type="text" name="telefone" size="20" 
                                        placeholder="Coloque o telefone"></label><br/><br/>
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
                </label><br/><br/>
                <label>Palavra-Passe: <input type="password" name="palavra_passe" size="20" 
                                        placeholder="Coloque a palavra-passe"></label><br/><br/>
                <label>Data Nascimento: <input type="date" name="data_nascimento"></label><br/><br/>
                <input type="submit" value="Inserir" class="bt">
            </form>
        <%
        }
        %>
        <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
    </body>
</html>
