<%@ page language="java" contentType="text/html; charset=UTF-8" 
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gerir Jogadores</title>
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
                String id_equipa = request.getParameter("id_equipa");
                String primeiro_nome = request.getParameter("primeiro_nome");
                String ultimo_nome = request.getParameter("ultimo_nome");
                String numero_camisola = request.getParameter("numero_camisola");
                String posicao = request.getParameter("posicao");
                String foto_url = request.getParameter("foto_url");
                
                String sql = "INSERT INTO t_jogadores (id_equipa, primeiro_nome, ultimo_nome, numero_camisola, posicao, foto_url) VALUES (?, ?, ?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                
                statement.setString(1, id_equipa);
                statement.setString(2, primeiro_nome);
                statement.setString(3, ultimo_nome);
                statement.setString(4, numero_camisola);
                statement.setString(5, posicao);
                statement.setString(6, foto_url);
                
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
                String sql = "DELETE FROM t_jogadores WHERE id_jogador=?";
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
    <h1>Gerir Jogadores</h1>
    
    <table border="1">
        <tr>
            <th>Id Jogador</th>
            <th>Id Equipa</th>
            <th>Primeiro Nome</th>
            <th>Último Nome</th>
            <th>Número Camisola</th>
            <th>Posição</th>
            <th>Foto</th>
        </tr>

<%
    int num = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
        Statement stmt = conn.createStatement();

        ResultSet rs = stmt.executeQuery("SELECT * FROM t_jogadores");
        
        while (rs.next()) {
%>
            <tr>
                <td><%= rs.getInt("id_jogador") %></td>
                <td><%= rs.getInt("id_equipa") %></td>
                <td><%= rs.getString("primeiro_nome") %></td>
                <td><%= rs.getString("ultimo_nome") %></td>
                <td><%= rs.getInt("numero_camisola") %></td>
                <td><%= rs.getString("posicao") %></td>
                <td><%= rs.getString("foto_url") %></td>
                <td>
                    <form method="post" action="GerirJogadores.jsp">
                        <input type="hidden" name="acao" value="apagar">
                        <input type="hidden" value="<%= rs.getInt("id_jogador") %>" name="id">
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

    <h3>Inserir Jogador</h3>
    <form method="post" action="GerirJogadores.jsp">
        <input type="hidden" name="acao" value="inserir">
        <label>Equipa: 
            <select name="id_equipa">
        <%
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection connEquipas = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");

                Statement stmtEquipas = connEquipas.createStatement();
                ResultSet rsEquipas = stmtEquipas.executeQuery("SELECT id_equipa, nome_equipa FROM t_equipas");

                while (rsEquipas.next()) {
        %>
                    <option value="<%= rsEquipas.getInt("id_equipa") %>"><%= rsEquipas.getString("nome_equipa") %></option>
        <%
                }

                rsEquipas.close();
                stmtEquipas.close();
                connEquipas.close();
            } catch (Exception e) {
                out.println("Erro ao carregar equipas: " + e.getMessage());
            }
        %>
        
            </select>
       <br>
        
        </label><br>
        <label>Primeiro Nome: <input type="text" name="primeiro_nome"></label><br>
        <br>
        <label>Último Nome: <input type="text" name="ultimo_nome"></label><br>
        <br>
        <label>Número Camisola: <input type="text" name="numero_camisola"></label><br>
        <br>
        <label>Posição: <input type="text" name="posicao"></label><br>
        <br>
        <label>Foto URL: <input type="text" name="foto_url"></label><br>
        <br>
        <input type="submit" value="Inserir"><br><br>
    </form>

    <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
</body>
</html>