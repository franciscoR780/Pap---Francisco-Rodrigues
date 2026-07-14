<%@ page language="java" contentType="text/html; charset=UTF-8" 
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gerir Equipas</title>
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
            
            if ("inserir".equals(acao)) {
                String nome_equipa = request.getParameter("nome_equipa");
                String categoria = request.getParameter("categoria");
                String temporada = request.getParameter("temporada");
                String data_criacao = request.getParameter("data_criacao");
                
                String sql = "INSERT INTO t_equipas (nome_equipa, categoria, temporada, data_criacao) VALUES (?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                
                statement.setString(1, nome_equipa);
                statement.setString(2, categoria);
                statement.setString(3, temporada);
                statement.setString(4, data_criacao);
                
                int rowsInserted = statement.executeUpdate();
                out.println(rowsInserted > 0 ? "<h2>Registo inserido com sucesso.</h2>" : "Erro na inserção.");
                
                statement.close();
            } 
            else if ("apagar".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                
                String sql = "DELETE FROM t_equipas WHERE id_equipa=?";
                PreparedStatement stm = conn.prepareStatement(sql);
                stm.setInt(1, id);
                
                int rowsDeleted = stm.executeUpdate();
                out.println(rowsDeleted > 0 ? "<h2>Registo apagado com sucesso.</h2>" :
                                               "Não existe nenhum registo com esse id: " + id);
                
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
    <h1>Gerir Equipas</h1>

    <!-- ========================= -->
    <!--      TABELA EM PRIMEIRO   -->
    <!-- ========================= -->

    <table border="1">
        <tr>
            <th>Id Equipa</th>
            <th>Nome Equipa</th>
            <th>Categoria</th>
            <th>Temporada</th>
            <th>Data Criação</th>
            <th>Ações</th>
        </tr>

<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
        
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT * FROM t_equipas");
        
        while (rs.next()) {
%>
        <tr>
            <td><%= rs.getInt("id_equipa") %></td>
            <td><%= rs.getString("nome_equipa") %></td>
            <td><%= rs.getString("categoria") %></td>
            <td><%= rs.getString("temporada") %></td>
            <td><%= rs.getDate("data_criacao") %></td>

            <td>
                <form method="post" style="display:inline;">
                    <input type="hidden" name="acao" value="apagar">
                    <input type="hidden" name="id" value="<%= rs.getInt("id_equipa") %>">
                    <input type="submit" value="Apagar">
                </form>
            </td>
        </tr>
<%
        }

        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("Erro ao carregar tabela: " + e.getMessage());
    }
%>

    </table>

    <br><br>

    <!-- ========================= -->
    <!--   FORMULÁRIO DE INSERIR   -->
    <!-- ========================= -->

    <form method="post">
        <input type="hidden" name="acao" value="inserir">

        Nome Equipa:
        <input type="text" name="nome_equipa"><br>

        Categoria:
        <input type="text" name="categoria"><br>

        Temporada:
        <input type="text" name="temporada"><br>

        Data Criação:
        <input type="date" name="data_criacao"><br>

        <input type="submit" value="Inserir">
    </form>

    
        <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
</body>
</html>
