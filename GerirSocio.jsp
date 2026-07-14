<%-- 
    Document   : GerirSocio
    Created on : 13/11/2025, 09:25:45
    Author     : Aluno
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" 
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gerir Socios</title>
    <link href="style.css" rel="stylesheet" type="text/css">
<%
    if (request.getMethod().equals("POST")) {
        String acao = request.getParameter("acao");

        String url = "jdbc:mysql://localhost:3306/pap";
        String username = "root";
        String password = "";
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, username, password);
            
            if (acao.equals("inserir")) {

                String numero = request.getParameter("numero_socio");
                String telemovel = request.getParameter("telemovel");
                String cartao_cidadao = request.getParameter("cartao_de_cidadao");
                String id_utilizador = request.getParameter("id_utilizador");
                String data_nascimento = request.getParameter("data_nascimento");

                String sql = "INSERT INTO t_socio (numero_socio, telemovel, cartao_de_cidadao, id_utilizador, data_nascimento) VALUES (?, ?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                statement.setString(1, numero);
                statement.setString(2, telemovel);
                statement.setString(3, cartao_cidadao);
                statement.setString(4, id_utilizador);
                statement.setString(5, data_nascimento);

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

                String sql = "DELETE FROM t_socio WHERE id_socio=?";
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
    <h1>Gerir Sócios</h1>
    
<%
    int num = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
        Statement stmt = conn.createStatement();

        ResultSet rs = stmt.executeQuery("SELECT * FROM t_socio");
%>
    <table border="1">
        <tr>
            <th>Id</th>
            <th>Id_Utilizador</th>
            <th>Número de Sócio</th>
            <th>Telemóvel</th>
            <th>Cartão Cidadão</th>
            <th>Data Nascimento</th>
            <th>Quota Anual</th>
            <th>Data de Inscrição</th>
            <th>Ação</th>
        </tr>
<%        
        while (rs.next()) {
%>
            <tr>
                <td><%= rs.getInt("id_socio") %></td>
                <td><%= rs.getInt("id_utilizador") %></td>
                <td><%= rs.getString("numero_socio") %></td>
                <td><%= rs.getString("telemovel") %></td>
                <td><%= rs.getString("cartao_de_cidadao") %></td>
                <td><%= rs.getDate("data_nascimento") %></td>
                <td><%= rs.getBigDecimal("quota_anual") %></td>
                <td><%= rs.getDate("data_inscricao") %></td>
                <td>
                    <form method="post" action="GerirSocio.jsp">
                        <input type="hidden" name="acao" value="apagar">
                        <input type="hidden" value="<%= rs.getInt("id_socio") %>" name="id">
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

    <h3>Inserir Sócio</h3>
    <form method="post" action="GerirSocio.jsp">
        <input type="hidden" name="acao" value="inserir">
        
        
        
        <label>Utilizador: 
            <select name="id_utilizador" required>
                <option value="">Selecione...</option>
                <%
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection connEquipas = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");

                        Statement stmtEquipas = connEquipas.createStatement();
                        ResultSet rsEquipas = stmtEquipas.executeQuery("SELECT id_utilizador, primeiro_nome, ultimo_nome FROM t_utilizadores");

                        while (rsEquipas.next()) {
                %>
                            <option value="<%= rsEquipas.getInt("id_utilizador") %>"><%= rsEquipas.getString("primeiro_nome") %> <%= rsEquipas.getString("ultimo_nome") %></option>
                <%          
                        }

                        rsEquipas.close();
                        stmtEquipas.close();
                        connEquipas.close();
                    } catch (Exception e) {
                        out.println("Erro ao carregar utilizador: " + e.getMessage());
                    }
                %>
            </select>
        </label><br/><br/>
        <label>Número de Sócio: <input type="text" name="numero_socio" required></label><br/><br/>
        <label>Telemóvel: <input type="text" name="telemovel" size="20" placeholder="Coloque o seu nº de telemóvel" required></label><br/><br/>
        <label>Cartão de Cidadão: <input type="text" name="cartao_de_cidadao" size="20" placeholder="Nº do Cartão de Cidadão" required></label><br/><br/>
        <label>Data Nascimento: <input type="date" name="data_nascimento"></label><br/><br/>
        <input type="submit" value="Inserir"><br><br>
    </form>

    <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
</body>
</html>