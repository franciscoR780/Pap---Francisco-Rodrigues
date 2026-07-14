<%-- 
    Document   : InserirTreinadores
    Created on : Dec 14, 2025, 1:26:43 PM
    Author     : Francisco
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
        <title>Inserção de Treinadores</title>
    </head>
    <body>
        <h1>Inserir Treinador</h1>
        <%
        if (request.getMethod().equals("POST")) {
            String id_equipa = request.getParameter("id_equipa");
            String primeiro_nome = request.getParameter("primeiro_nome");
            String ultimo_nome = request.getParameter("ultimo_nome");
            String data_nascimento = request.getParameter("data_nascimento");
            String nacionalidade = request.getParameter("nacionalidade");
            String nivel_treinador = request.getParameter("nivel_treinador");
            String telefone = request.getParameter("telefone");
            String email = request.getParameter("email");
            String foto_url = request.getParameter("foto_url");
            String data_contratacao = request.getParameter("data_contratacao");
            String salario = request.getParameter("salario");
            String ativo = request.getParameter("ativo");
            String observacoes = request.getParameter("observacoes");
            
            String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
            String username = "root";
            String password = "";
            
            try { 
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(url, username, password);
                
                String sql = "INSERT INTO t_treinadores (id_equipa, primeiro_nome, ultimo_nome, data_nascimento, nacionalidade, nivel_treinador, telefone, email, foto_url, data_contratacao, salario, ativo, observacoes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                
                if (id_equipa.isEmpty()) {
                    statement.setNull(1, Types.INTEGER);
                } else {
                    statement.setInt(1, Integer.parseInt(id_equipa));
                }
                statement.setString(2, primeiro_nome);
                statement.setString(3, ultimo_nome);
                if (data_nascimento.isEmpty()) {
                    statement.setNull(4, Types.DATE);
                } else {
                    statement.setDate(4, Date.valueOf(data_nascimento));
                }
                statement.setString(5, nacionalidade.isEmpty() ? null : nacionalidade);
                statement.setString(6, nivel_treinador);
                statement.setString(7, telefone.isEmpty() ? null : telefone);
                statement.setString(8, email.isEmpty() ? null : email);
                statement.setString(9, foto_url.isEmpty() ? null : foto_url);
                if (data_contratacao.isEmpty()) {
                    statement.setNull(10, Types.DATE);
                } else {
                    statement.setDate(10, Date.valueOf(data_contratacao));
                }
                if (salario.isEmpty()) {
                    statement.setNull(11, Types.DECIMAL);
                } else {
                    statement.setBigDecimal(11, new java.math.BigDecimal(salario));
                }
                statement.setInt(12, Integer.parseInt(ativo));
                statement.setString(13, observacoes.isEmpty() ? null : observacoes);
                
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
            <form method="post" action="InserirTreinadores.jsp">
                <label>Equipa: 
                <select name="id_equipa">
                    <option value="">Sem equipa</option>
                    <%
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery("SELECT id_equipa, nome_equipa FROM t_equipas");
                        
                        while (rs.next()) {
                            out.println("<option value='" + rs.getInt("id_equipa") + "'>" + rs.getString("nome_equipa") + "</option>");
                        }
                        
                        rs.close();
                        stmt.close();
                        conn.close();
                    } catch (Exception e) {
                        out.println("Erro: " + e.getMessage());
                    }
                    %>
                </select>
                </label><br/><br/>
                
                <label>Primeiro Nome: <input type="text" name="primeiro_nome" size="30" required></label><br/><br/>
                
                <label>Último Nome: <input type="text" name="ultimo_nome" size="30" required></label><br/><br/>
                
                <label>Data Nascimento: <input type="date" name="data_nascimento"></label><br/><br/>
                
                <label>Nacionalidade: <input type="text" name="nacionalidade" size="30" value=""></label><br/><br/>
                
                <label>Nível Treinador: 
                <select name="nivel_treinador">
                    <option value="UEFA C">UEFA C</option>
                    <option value="UEFA B">UEFA B</option>
                    <option value="UEFA A">UEFA A</option>
                    <option value="UEFA Pro">UEFA Pro</option>
                    <option value="Estagiário" selected>Estagiário</option>
                </select>
                </label><br/><br/>
                
                <label>Telefone: <input type="text" name="telefone" size="20" placeholder="912345678"></label><br/><br/>
                
                <label>Email: <input type="email" name="email" size="40"></label><br/><br/>
                
                <label>URL da Foto: <input type="text" name="foto_url" size="50" placeholder="images/treinadores/foto.jpg"></label><br/><br/>
                
                <label>Data Contratação: <input type="date" name="data_contratacao"></label><br/><br/>
                
                <label>Salário (€): <input type="number" name="salario" step="0.01" value="" min="0"></label><br/><br/>
                
                <label>Ativo: 
                <select name="ativo">
                    <option value="1" selected>Sim</option>
                    <option value="0">Não</option>
                </select>
                </label><br/><br/>
                
                <label>Observações:<br>
                <textarea name="observacoes" rows="4" cols="50"></textarea>
                </label><br/><br/>
                
                <input type="submit" value="Inserir" class="bt">
            </form>
        <%
        }
        %>
        <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
    </body>
</html>