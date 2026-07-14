<%-- 
    Document   : GerirVendasBilhetes
    Created on : Dec 23, 2025
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" 
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gerir Vendas de Bilhetes</title>
    <link href="style.css" rel="stylesheet" type="text/css">
    <style>
        .badge {
            padding: 0.3rem 0.8rem;
            border-radius: 12px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-block;
        }
        .badge-pendente {
            background: #FFF3CD;
            color: #856404;
        }
        .badge-pago {
            background: #D4EDDA;
            color: #155724;
        }
        .badge-falhado {
            background: #F8D7DA;
            color: #721C24;
        }
        .badge-reembolsado {
            background: #E2E3E5;
            color: #383D41;
        }
        table {
            font-size: 0.9rem;
        }
        td, th {
            padding: 8px;
        }
    </style>

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
                String quantidade_bilhetes = request.getParameter("quantidade_bilhetes");
                String valor_total = request.getParameter("valor_total");
                String metodo_pagamento = request.getParameter("metodo_pagamento");
                String estado_pagamento = request.getParameter("estado_pagamento");
                String email_envio = request.getParameter("email_envio");
                String observacoes = request.getParameter("observacoes");
                
                // Gerar número de venda único
                String numeroVenda = "VB" + System.currentTimeMillis();
                
                String sql = "INSERT INTO t_vendas_bilhetes (id_utilizador, numero_venda, data_venda, quantidade_bilhetes, valor_total, metodo_pagamento, estado_pagamento, email_envio, observacoes) VALUES (?, ?, NOW(), ?, ?, ?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                
                statement.setObject(1, id_utilizador.isEmpty() ? null : Integer.parseInt(id_utilizador));
                statement.setString(2, numeroVenda);
                statement.setInt(3, Integer.parseInt(quantidade_bilhetes));
                statement.setDouble(4, Double.parseDouble(valor_total));
                statement.setString(5, metodo_pagamento);
                statement.setString(6, estado_pagamento);
                statement.setString(7, email_envio.isEmpty() ? null : email_envio);
                statement.setString(8, observacoes.isEmpty() ? null : observacoes);
                
                int rowsInserted = statement.executeUpdate();
                out.println(rowsInserted > 0 ? "<h2>Venda inserida com sucesso! Nº Venda: " + numeroVenda + "</h2>" : "Erro na inserção.");
                
                statement.close();
            } 
            else if ("apagar".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                
                String sql = "DELETE FROM t_vendas_bilhetes WHERE id_venda=?";
                PreparedStatement stm = conn.prepareStatement(sql);
                stm.setInt(1, id);
                
                int rowsDeleted = stm.executeUpdate();
                out.println(rowsDeleted > 0 ? "<h2>Venda apagada com sucesso.</h2>" :
                                               "Não existe nenhuma venda com esse id: " + id);
                
                stm.close();
            }
            else if ("atualizar_estado".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String novoEstado = request.getParameter("novo_estado");
                
                String sql = "UPDATE t_vendas_bilhetes SET estado_pagamento=? WHERE id_venda=?";
                PreparedStatement stm = conn.prepareStatement(sql);
                stm.setString(1, novoEstado);
                stm.setInt(2, id);
                
                int rowsUpdated = stm.executeUpdate();
                out.println(rowsUpdated > 0 ? "<h2>Estado atualizado com sucesso.</h2>" : "Erro ao atualizar estado.");
                
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
    <h1>Gerir Vendas de Bilhetes</h1>

    <!-- ========================= -->
    <!--      TABELA EM PRIMEIRO   -->
    <!-- ========================= -->

    <table border="1">
        <tr>
            <th>Id</th>
            <th>Nº Venda</th>
            <th>Utilizador</th>
            <th>Data Venda</th>
            <th>Quantidade</th>
            <th>Valor Total</th>
            <th>Método Pag.</th>
            <th>Estado</th>
            <th>Email Envio</th>
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
            "SELECT v.*, " +
            "CONCAT(u.primeiro_nome, ' ', u.ultimo_nome) as nome_utilizador, " +
            "u.email as email_utilizador " +
            "FROM t_vendas_bilhetes v " +
            "LEFT JOIN t_utilizadores u ON v.id_utilizador = u.id_utilizador " +
            "ORDER BY v.id_venda DESC"
        );
        
        while (rs.next()) {
            String estado = rs.getString("estado_pagamento");
            String badgeClass = "badge-" + estado;
            String obs = rs.getString("observacoes");
%>
        <tr>
            <td><%= rs.getInt("id_venda") %></td>
            <td><strong><%= rs.getString("numero_venda") %></strong></td>
            <td>
                <% if (rs.getString("nome_utilizador") != null) { %>
                    <%= rs.getString("nome_utilizador") %><br/>
                    <small style="color: #666;"><%= rs.getString("email_utilizador") %></small>
                <% } else { %>
                    <span style="color: #999;">Sem utilizador</span>
                <% } %>
            </td>
            <td><%= rs.getTimestamp("data_venda") %></td>
            <td><strong><%= rs.getInt("quantidade_bilhetes") %></strong> bilhete(s)</td>
            <td><strong><%= String.format("%.2f€", rs.getDouble("valor_total")) %></strong></td>
            <td><%= rs.getString("metodo_pagamento").toUpperCase() %></td>
            <td>
                <span class="badge <%= badgeClass %>">
                    <%= estado.toUpperCase() %>
                </span>
                
                <!-- Form para atualizar estado -->
                <form method="post" style="display:inline; margin-top: 5px;">
                    <input type="hidden" name="acao" value="atualizar_estado">
                    <input type="hidden" name="id" value="<%= rs.getInt("id_venda") %>">
                    <select name="novo_estado" style="font-size: 0.8rem;">
                        <option value="pendente" <%= estado.equals("pendente") ? "selected" : "" %>>Pendente</option>
                        <option value="pago" <%= estado.equals("pago") ? "selected" : "" %>>Pago</option>
                        <option value="falhado" <%= estado.equals("falhado") ? "selected" : "" %>>Falhado</option>
                        <option value="reembolsado" <%= estado.equals("reembolsado") ? "selected" : "" %>>Reembolsado</option>
                    </select>
                    <input type="submit" value="Atualizar" style="font-size: 0.8rem;">
                </form>
            </td>
            <td><%= rs.getString("email_envio") != null ? rs.getString("email_envio") : "-" %></td>
            <td><%= obs != null ? obs : "-" %></td>

            <td>
                <form method="post" style="display:inline;">
                    <input type="hidden" name="acao" value="apagar">
                    <input type="hidden" name="id" value="<%= rs.getInt("id_venda") %>">
                    <input type="submit" value="Apagar" onclick="return confirm('Tem certeza que deseja apagar esta venda?');">
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

    <h2>Inserir Nova Venda</h2>
    <form method="post">
        <input type="hidden" name="acao" value="inserir">

        Utilizador (opcional):
        <select name="id_utilizador">
            <option value="">Sem utilizador registado</option>
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT id_utilizador, primeiro_nome, ultimo_nome, email FROM t_utilizadores ORDER BY primeiro_nome");
                    
                    while (rs.next()) {
            %>
                        <option value="<%= rs.getInt("id_utilizador") %>">
                            <%= rs.getString("primeiro_nome") %> <%= rs.getString("ultimo_nome") %> (<%= rs.getString("email") %>)
                        </option>
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

        Quantidade de Bilhetes:
        <input type="number" name="quantidade_bilhetes" value="1" min="1" required><br>

        Valor Total:
        <input type="number" step="0.01" name="valor_total" required placeholder="0.00"><br>

        Método Pagamento:
        <select name="metodo_pagamento" required>
            <option value="">Selecione...</option>
            <option value="multibanco">Multibanco</option>
            <option value="mbway">MBWay</option>
            <option value="cartao">Cartão</option>
            <option value="paypal">PayPal</option>
            <option value="dinheiro">Dinheiro</option>
        </select><br>

        Estado do Pagamento:
        <select name="estado_pagamento" required>
            <option value="pendente" selected>Pendente</option>
            <option value="pago">Pago</option>
            <option value="falhado">Falhado</option>
            <option value="reembolsado">Reembolsado</option>
        </select><br>

        Email para Envio:
        <input type="email" name="email_envio" placeholder="email@exemplo.com"><br>

        Observações:
        <textarea name="observacoes" rows="3" cols="40" placeholder="Observações adicionais (opcional)"></textarea><br>

        <input type="submit" value="Inserir Venda">
    </form>

    
    <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
</body>
</html>