<%-- 
    Document   : GerirFaturas
    Created on : Dec 15, 2025, 1:28:57 AM
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" 
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gerir Faturas</title>
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
                String id_utilizador = request.getParameter("id_utilizador");
                String id_encomenda = request.getParameter("id_encomenda");
                String data_emissao = request.getParameter("data_emissao");
                String data_pagamento = request.getParameter("data_pagamento");
                String metodo_pagamento = request.getParameter("metodo_pagamento");
                String valor_subtotal = request.getParameter("valor_subtotal");
                String valor_iva = request.getParameter("valor_iva");
                String valor_desconto = request.getParameter("valor_desconto");
                String observacoes = request.getParameter("observacoes");
                
                String sql = "INSERT INTO t_fatura (id_utilizador, id_encomenda, data_emissao, data_pagamento, metodo_pagamento, valor_subtotal, valor_iva, valor_desconto, observacoes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                
                statement.setInt(1, Integer.parseInt(id_utilizador));
                
                if (id_encomenda != null && !id_encomenda.trim().isEmpty()) {
                    statement.setInt(2, Integer.parseInt(id_encomenda));
                } else {
                    statement.setNull(2, Types.INTEGER);
                }
                
                statement.setString(3, data_emissao);
                
                if (data_pagamento != null && !data_pagamento.trim().isEmpty()) {
                    statement.setString(4, data_pagamento);
                } else {
                    statement.setNull(4, Types.DATE);
                }
                
                statement.setString(5, metodo_pagamento);
                statement.setDouble(6, Double.parseDouble(valor_subtotal));
                statement.setDouble(7, Double.parseDouble(valor_iva));
                statement.setDouble(8, Double.parseDouble(valor_desconto));
                
                if (observacoes != null && !observacoes.trim().isEmpty()) {
                    statement.setString(9, observacoes);
                } else {
                    statement.setNull(9, Types.VARCHAR);
                }
                
                int rowsInserted = statement.executeUpdate();
                out.println(rowsInserted > 0 ? "<h2>Registo inserido com sucesso.</h2>" : "Erro na inserção.");
                
                statement.close();
            } 
            else if ("apagar".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                
                String sql = "DELETE FROM t_fatura WHERE id_fatura=?";
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
    <h1>Gerir Faturas</h1>

    <!-- ========================= -->
    <!--      TABELA EM PRIMEIRO   -->
    <!-- ========================= -->

    <table border="1">
        <tr>
            <th>Id Fatura</th>
            <th>Utilizador</th>
            <th>Id Encomenda</th>
            <th>Data Emissão</th>
            <th>Data Pagamento</th>
            <th>Método Pagamento</th>
            <th>Valor Subtotal</th>
            <th>Valor IVA</th>
            <th>Valor Desconto</th>
            <th>Observações</th>
            <th>Ações</th>
        </tr>

<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
        
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(
            "SELECT f.*, u.nome as nome_utilizador, u.email " +
            "FROM t_fatura f " +
            "INNER JOIN t_utilizadores u ON f.id_utilizador = u.id_utilizador " +
            "ORDER BY f.id_fatura DESC"
        );
        
        while (rs.next()) {
%>
        <tr>
            <td><%= rs.getInt("id_fatura") %></td>
            <td><%= rs.getString("nome_utilizador") %> (<%= rs.getString("email") %>)</td>
            <td><%= rs.getObject("id_encomenda") != null ? rs.getInt("id_encomenda") : "N/A" %></td>
            <td><%= rs.getDate("data_emissao") %></td>
            <td><%= rs.getDate("data_pagamento") != null ? rs.getDate("data_pagamento") : "Pendente" %></td>
            <td><%= rs.getString("metodo_pagamento") %></td>
            <td><%= String.format("%.2f€", rs.getDouble("valor_subtotal")) %></td>
            <td><%= String.format("%.2f€", rs.getDouble("valor_iva")) %></td>
            <td><%= String.format("%.2f€", rs.getDouble("valor_desconto")) %></td>
            <td><%= rs.getString("observacoes") != null ? rs.getString("observacoes") : "" %></td>

            <td>
                <form method="post" style="display:inline;">
                    <input type="hidden" name="acao" value="apagar">
                    <input type="hidden" name="id" value="<%= rs.getInt("id_fatura") %>">
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

        Utilizador:
        <select name="id_utilizador" required>
            <option value="">Selecione o utilizador...</option>
            <%
                String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
                String username = "root";
                String password = "";
                
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(url, username, password);
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT id_utilizador, nome, email FROM t_utilizadores ORDER BY nome");
                    
                    while (rs.next()) {
                        int idUser = rs.getInt("id_utilizador");
                        String nome = rs.getString("nome");
                        String email = rs.getString("email");
            %>
                        <option value="<%= idUser %>"><%= nome %> (<%= email %>)</option>
            <%
                    }
                    rs.close();
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<option value=''>Erro ao carregar utilizadores</option>");
                }
            %>
        </select><br>

        Id Encomenda:
        <input type="number" name="id_encomenda"><br>

        Data Emissão:
        <input type="date" name="data_emissao" required><br>

        Data Pagamento:
        <input type="date" name="data_pagamento"><br>

        Método Pagamento:
        <select name="metodo_pagamento" required>
            <option value="">Selecione...</option>
            <option value="multibanco">Multibanco</option>
            <option value="mbway">MBWay</option>
            <option value="cartao">Cartão</option>
            <option value="paypal">PayPal</option>
        </select><br>

        Valor Subtotal:
        <input type="number" step="0.01" name="valor_subtotal" required><br>

        Valor IVA:
        <input type="number" step="0.01" name="valor_iva" value="0.00"><br>

        Valor Desconto:
        <input type="number" step="0.01" name="valor_desconto" value="0.00"><br>

        Observações:
        <textarea name="observacoes" rows="4" cols="30"></textarea><br>

        <input type="submit" value="Inserir">
    </form>

    
    <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
</body>
</html>