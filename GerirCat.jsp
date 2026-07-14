<%-- 
    Document   : GerirCat
    Created on : 11/11/2025, 11:28:24
    Author     : Aluno
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" 
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gerir Categorias</title>
    <link href="style.css" rel="stylesheet" type="text/css">
<%
    if (request.getMethod().equals("POST")) {
        String acao = request.getParameter("acao");

        String url = "jdbc:mysql://localhost:3306/pap";
        String username = "root";
        String password = "";
        
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, username, password);
            
            if (acao.equals("inserir")) {

                String numero = request.getParameter("nome");

                String sql = "INSERT INTO t_categoria (nome) VALUES (?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                statement.setString(1, numero);

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

                String sql = "DELETE FROM t_categoria WHERE id_categoria=?";
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
    <h1>Gerir Categorias</h1>
    
    <table border="1">
        <tr>
            <th>ID Categoria</th>
            <th>Nome</th>
            <th>Descrição</th>
            <th>Ativo</th>
            <th>Imagem</th>
            <th>Ordem</th>
            <th>Data Criação</th>
            <th>Data Atualização</th>

        </tr>

<%
    int num = 0;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
        Statement stmt = conn.createStatement();

        ResultSet rs = stmt.executeQuery("SELECT * FROM t_categoria");
        
        while (rs.next()) {
%>
            <tr>
                    <td><%= rs.getInt("id_categoria") %></td>
                    <td><%= rs.getString("nome") %></td>
                    <td><%= rs.getString("descricao") %></td>
                    <td><%= rs.getInt("ativo") %></td>
                    <td><%= rs.getString("imagem") %></td>
                    <td><%= rs.getInt("ordem") %></td>
                    <td><%= rs.getString("data_criacao") %></td>
                    <td><%= rs.getString("data_atualizacao") %></td>

                <td>
                    <form method="post" action="GerirCat.jsp">
                        <input type="hidden" name="acao" value="apagar">
                        <input type="hidden" value="<%= rs.getInt("id_categoria") %>" name="id">
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

    <h3>Inserir Categorias</h3>
    <form method="post" action="GerirCat.jsp">
        <input type="hidden" name="acao" value="inserir">
        <label>Inserir Categoria: <input type="text" name="nome"></label>
        <input type="submit" value="Inserir"><br><br>
    </form>

    <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
</body>
</html>


