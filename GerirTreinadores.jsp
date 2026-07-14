<%-- 
    Document   : GerirTreinadores
    Created on : Dec 14, 2025, 1:27:02 PM
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" 
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gerir Treinadores</title>
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
                out.println(rowsInserted > 0 ? "<h2>Registo inserido com sucesso.</h2>" : "Erro na inserção.");
                
                statement.close();
            } 
            else if ("apagar".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                
                String sql = "DELETE FROM t_treinadores WHERE id_treinador=?";
                PreparedStatement stm = conn.prepareStatement(sql);
                stm.setInt(1, id);
                
                int rowsDeleted = stm.executeUpdate();
                out.println(rowsDeleted > 0 ? "<h2>Registo apagado com sucesso.</h2>" :
                                               "Não existe nenhum registo com esse id: " + id);
                
                stm.close();
            }
            else if ("alterar_ativo".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                int novo_ativo = Integer.parseInt(request.getParameter("novo_ativo"));
                
                String sql = "UPDATE t_treinadores SET ativo=? WHERE id_treinador=?";
                PreparedStatement stm = conn.prepareStatement(sql);
                stm.setInt(1, novo_ativo);
                stm.setInt(2, id);
                
                int rowsUpdated = stm.executeUpdate();
                out.println(rowsUpdated > 0 ? "<h2>Estado alterado com sucesso.</h2>" : "Erro ao alterar estado.");
                
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
    <h1>Gerir Treinadores</h1>

    <!-- ========================= -->
    <!--      TABELA EM PRIMEIRO   -->
    <!-- ========================= -->

    <table border="1">
        <tr>
            <th>Id</th>
            <th>Nome Completo</th>
            <th>Equipa</th>
            <th>Nível</th>
            <th>Telefone</th>
            <th>Salário</th>
            <th>Ativo</th>
            <th>Ações</th>
        </tr>

<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
        
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(
            "SELECT t.*, e.nome_equipa " +
            "FROM t_treinadores t " +
            "LEFT JOIN t_equipas e ON t.id_equipa = e.id_equipa"
        );
        
        while (rs.next()) {
            String nomeCompleto = rs.getString("primeiro_nome") + " " + rs.getString("ultimo_nome");
            String nomeEquipa = rs.getString("nome_equipa");
            if (nomeEquipa == null) nomeEquipa = "Sem equipa";
            
            int ativo = rs.getInt("ativo");
            String corAtivo = "";
            if (ativo == 1) {
                corAtivo = "style='background-color: #90EE90;'";
            } else {
                corAtivo = "style='background-color: #FFB6C1;'";
            }
            
            java.math.BigDecimal salarioBD = rs.getBigDecimal("salario");
            String salarioStr = (salarioBD != null) ? salarioBD.toString() : "0.00";
%>
        <tr>
            <td><%= rs.getInt("id_treinador") %></td>
            <td><%= nomeCompleto %></td>
            <td><%= nomeEquipa %></td>
            <td><%= rs.getString("nivel_treinador") %></td>
            <td><%= rs.getString("telefone") != null ? rs.getString("telefone") : "-" %></td>
            <td><%= salarioStr %>€</td>
            <td <%= corAtivo %>><%= ativo == 1 ? "Sim" : "Não" %></td>

            <td>
                <!-- Alterar Estado Ativo -->
                <form method="post" style="display:inline;">
                    <input type="hidden" name="acao" value="alterar_ativo">
                    <input type="hidden" name="id" value="<%= rs.getInt("id_treinador") %>">
                    <select name="novo_ativo">
                        <option value="1">Ativo</option>
                        <option value="0">Inativo</option>
                    </select>
                    <input type="submit" value="Alterar">
                </form>
                
                <!-- Apagar -->
                <form method="post" style="display:inline;">
                    <input type="hidden" name="acao" value="apagar">
                    <input type="hidden" name="id" value="<%= rs.getInt("id_treinador") %>">
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
        </label><br><br>

        <label>Primeiro Nome: <input type="text" name="primeiro_nome" required></label><br><br>

        <label>Último Nome: <input type="text" name="ultimo_nome" required></label><br><br>

        <label>Data Nascimento: <input type="date" name="data_nascimento"></label><br><br>

        <label>Nacionalidade: <input type="text" name="nacionalidade" value=""></label><br><br>

        <label>Nível: 
        <select name="nivel_treinador">
            <option value="UEFA C">UEFA C</option>
            <option value="UEFA B">UEFA B</option>
            <option value="UEFA A">UEFA A</option>
            <option value="UEFA Pro">UEFA Pro</option>
            <option value="Estagiário" selected>Estagiário</option>
        </select>
        </label><br><br>

        <label>Telefone: <input type="text" name="telefone"></label><br><br>

        <label>Email: <input type="email" name="email"></label><br><br>

        <label>URL Foto: <input type="text" name="foto_url"></label><br><br>

        <label>Data Contratação: <input type="date" name="data_contratacao"></label><br><br>

        <label>Salário (€): <input type="number" name="salario" step="0.01" value=""></label><br><br>

        <label>Ativo: 
        <select name="ativo">
            <option value="1" selected>Sim</option>
            <option value="0">Não</option>
        </select>
        </label><br><br>

        <label>Observações:<br>
        <textarea name="observacoes" rows="3" cols="40"></textarea>
        </label><br><br>

        <input type="submit" value="Inserir" class="bt">
    </form>

    <br>
    <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
</body>
</html>