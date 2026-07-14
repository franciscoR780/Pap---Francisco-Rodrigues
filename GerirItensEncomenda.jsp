<%-- 
    Document   : GerirItensEncomenda
    Created on : Dec 15, 2025, 1:59:42 PM
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gerir Itens de Encomenda</title>
    <link href="style.css" rel="stylesheet" type="text/css">
    <style>
        .group-header {
            background: #FFD700;
            font-weight: bold;
            color: #0a0a0a;
        }
        .item-row {
            background: #f9f9f9;
        }
        .total-row {
            background: #e8f5e9;
            font-weight: bold;
        }
        .error-message {
            background: #ffebee;
            color: #c62828;
            padding: 10px;
            margin: 10px 0;
            border-radius: 4px;
            border: 1px solid #ef5350;
        }
        .success-message {
            background: #e8f5e9;
            color: #2e7d32;
            padding: 10px;
            margin: 10px 0;
            border-radius: 4px;
            border: 1px solid #66bb6a;
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
                String id_encomenda = request.getParameter("id_encomenda");
                String id_produto = request.getParameter("id_produto");
                String quantidade = request.getParameter("quantidade");
                String preco_unitario = request.getParameter("preco_unitario");
                String preco_total = request.getParameter("preco_total");
                
                String sql = "INSERT INTO t_itens_encomenda (id_encomenda, id_produto, quantidade, preco_unitario, preco_total) VALUES (?, ?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                
                statement.setInt(1, Integer.parseInt(id_encomenda));
                statement.setInt(2, Integer.parseInt(id_produto));
                statement.setInt(3, Integer.parseInt(quantidade));
                statement.setDouble(4, Double.parseDouble(preco_unitario));
                statement.setDouble(5, Double.parseDouble(preco_total));
                
                int rowsInserted = statement.executeUpdate();
                if (rowsInserted > 0) {
                    out.println("<div class='success-message'>✓ Item inserido com sucesso!</div>");
                } else {
                    out.println("<div class='error-message'>✗ Erro na inserção.</div>");
                }
                
                statement.close();
            } 
            else if ("apagar".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                
                String sql = "DELETE FROM t_itens_encomenda WHERE id_item=?";
                PreparedStatement stm = conn.prepareStatement(sql);
                stm.setInt(1, id);
                
                int rowsDeleted = stm.executeUpdate();
                if (rowsDeleted > 0) {
                    out.println("<div class='success-message'>✓ Item apagado com sucesso!</div>");
                } else {
                    out.println("<div class='error-message'>✗ Não existe nenhum item com esse ID: " + id + "</div>");
                }
                
                stm.close();
            }
            else if ("atualizar".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                int quantidade = Integer.parseInt(request.getParameter("quantidade"));
                double precoUnitario = Double.parseDouble(request.getParameter("preco_unitario"));
                double precoTotal = quantidade * precoUnitario;
                
                String sql = "UPDATE t_itens_encomenda SET quantidade=?, preco_unitario=?, preco_total=? WHERE id_item=?";
                PreparedStatement stm = conn.prepareStatement(sql);
                stm.setInt(1, quantidade);
                stm.setDouble(2, precoUnitario);
                stm.setDouble(3, precoTotal);
                stm.setInt(4, id);
                
                int rowsUpdated = stm.executeUpdate();
                if (rowsUpdated > 0) {
                    out.println("<div class='success-message'>✓ Item atualizado com sucesso!</div>");
                } else {
                    out.println("<div class='error-message'>✗ Erro ao atualizar item.</div>");
                }
                
                stm.close();
            }
            
            conn.close();
        } catch (SQLException e) {
            out.println("<div class='error-message'>✗ Erro SQL: " + e.getMessage() + "</div>");
        } catch (NumberFormatException e) {
            out.println("<div class='error-message'>✗ Erro: Valores numéricos inválidos.</div>");
        } catch (Exception e) {
            out.println("<div class='error-message'>✗ Ocorreu um erro: " + e.getMessage() + "</div>");
        }
    }
%>

</head>

<body>
    <h1>Gerir Itens de Encomenda</h1>

    <table border="1">
        <tr>
            <th>ID Item</th>
            <th>ID Encomenda</th>
            <th>Utilizador</th>
            <th>Produto</th>
            <th>Quantidade</th>
            <th>Preço Unitário</th>
            <th>Preço Total</th>
            <th>Ações</th>
        </tr>

<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
        
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(
            "SELECT t_itens_encomenda.id_item, t_itens_encomenda.id_encomenda, " +
            "t_itens_encomenda.id_produto, t_itens_encomenda.quantidade, t_itens_encomenda.preco_unitario, t_itens_encomenda.preco_total, " +
            "CONCAT(t_utilizadores.primeiro_nome, ' ', t_utilizadores.ultimo_nome) as nome_utilizador, " +
            "t_produtos.nome_produto, " +
            "t_encomendas.data_encomenda, t_encomendas.estado " +
            "FROM t_itens_encomenda " +
            "INNER JOIN t_encomendas ON t_itens_encomenda.id_encomenda = t_encomendas.id_encomenda " +
            "INNER JOIN t_utilizadores ON t_encomendas.id_utilizador = t_utilizadores.id_utilizador " +
            "LEFT JOIN t_produtos ON t_itens_encomenda.id_produto = t_produtos.id_produto " +
            "ORDER BY t_itens_encomenda.id_encomenda DESC, t_itens_encomenda.id_item DESC"
        );
        
        int currentEncomenda = -1;
        double subtotalEncomenda = 0.0;
        
        while (rs.next()) {
            int idEncomenda = rs.getInt("id_encomenda");
            
            if (currentEncomenda != -1 && currentEncomenda != idEncomenda) {
%>
                <tr class="total-row">
                    <td colspan="7" align="right"><strong>Subtotal Encomenda #<%= currentEncomenda %>:</strong></td>
                    <td><strong><%= String.format("%.2f€", subtotalEncomenda) %></strong></td>
                </tr>
<%
                subtotalEncomenda = 0.0;
            }
            
            if (currentEncomenda != idEncomenda) {
%>
                <tr class="group-header">
                    <td colspan="8">
                        <strong>Encomenda #<%= idEncomenda %></strong> - 
                        <%= rs.getString("nome_utilizador") %> - 
                        <%= rs.getString("data_encomenda") %> - 
                        Estado: <%= rs.getString("estado").toUpperCase() %>
                    </td>
                </tr>
<%
                currentEncomenda = idEncomenda;
            }
            
            double precoTotal = rs.getDouble("preco_total");
            subtotalEncomenda += precoTotal;
%>
        <tr class="item-row">
            <td><%= rs.getInt("id_item") %></td>
            <td><%= idEncomenda %></td>
            <td><%= rs.getString("nome_utilizador") %></td>
            <td><%= rs.getString("nome_produto") != null ? rs.getString("nome_produto") : "N/A" %></td>
            <td>
                <form method="post" style="display:inline;">
                    <input type="hidden" name="acao" value="atualizar">
                    <input type="hidden" name="id" value="<%= rs.getInt("id_item") %>">
                    <input type="number" name="quantidade" value="<%= rs.getInt("quantidade") %>" 
                           style="width: 60px;" min="1" required>
            </td>
            <td>
                    <input type="number" step="0.01" name="preco_unitario" 
                           value="<%= rs.getDouble("preco_unitario") %>" 
                           style="width: 80px;" required>
            </td>
            <td><%= String.format("%.2f€", precoTotal) %></td>
            <td>
                    <input type="submit" value="Atualizar" style="font-size: 0.8rem;">
                </form>
                
                <form method="post" style="display:inline; margin-left: 5px;">
                    <input type="hidden" name="acao" value="apagar">
                    <input type="hidden" name="id" value="<%= rs.getInt("id_item") %>">
                    <input type="submit" value="Apagar" 
                           onclick="return confirm('Tem certeza que deseja apagar este item?');"
                           style="font-size: 0.8rem;">
                </form>
            </td>
        </tr>
<%
        }
        
        if (currentEncomenda != -1) {
%>
            <tr class="total-row">
                <td colspan="7" align="right"><strong>Subtotal Encomenda #<%= currentEncomenda %>:</strong></td>
                <td><strong><%= String.format("%.2f€", subtotalEncomenda) %></strong></td>
            </tr>
<%
        }

        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("<tr><td colspan='8' class='error-message'>✗ Erro ao carregar tabela: " + e.getMessage() + "</td></tr>");
    }
%>

    </table>

    <br><br>

    <h2>Inserir Novo Item de Encomenda</h2>
    <form method="post">
        <input type="hidden" name="acao" value="inserir">

        <label>Encomenda:</label>
        <select name="id_encomenda" id="id_encomenda" required>
            <option value="">Selecione a encomenda...</option>
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery(
                        "SELECT t_encomendas.id_encomenda, t_encomendas.id_utilizador, t_encomendas.data_encomenda, t_encomendas.estado, " +
                        "CONCAT(t_utilizadores.primeiro_nome, ' ', t_utilizadores.ultimo_nome) as nome_utilizador " +
                        "FROM t_encomendas " +
                        "INNER JOIN t_utilizadores ON t_encomendas.id_utilizador = t_utilizadores.id_utilizador " +
                        "ORDER BY t_encomendas.id_encomenda DESC"
                    );
                    
                    while (rs.next()) {
            %>
                        <option value="<%= rs.getInt("id_encomenda") %>">
                            #<%= rs.getInt("id_encomenda") %> - <%= rs.getString("nome_utilizador") %> - 
                            <%= rs.getString("data_encomenda") %> (<%= rs.getString("estado") %>)
                        </option>
            <%
                    }
                    rs.close();
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<option value=''>Erro ao carregar encomendas</option>");
                }
            %>
        </select><br><br>

        <label>Produto:</label>
        <select name="id_produto" id="id_produto" required onchange="carregarPrecoProduto()">
            <option value="">Selecione o produto...</option>
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT id_produto, nome_produto, preco FROM t_produtos ORDER BY nome_produto");
                    
                    while (rs.next()) {
            %>
                        <option value="<%= rs.getInt("id_produto") %>" data-preco="<%= rs.getDouble("preco") %>">
                            <%= rs.getString("nome_produto") %> - <%= String.format("%.2f€", rs.getDouble("preco")) %>
                        </option>
            <%
                    }
                    rs.close();
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<option value=''>Erro ao carregar produtos</option>");
                }
            %>
        </select><br><br>

        <label>Quantidade:</label>
        <input type="number" name="quantidade" id="quantidade" min="1" required onchange="calcularTotal()"><br><br>

        <label>Preço Unitário:</label>
        <input type="number" step="0.01" name="preco_unitario" id="preco_unitario" required onchange="calcularTotal()"><br><br>

        <label>Preço Total:</label>
        <input type="number" step="0.01" name="preco_total" id="preco_total" required readonly 
               style="background: #f0f0f0;"><br><br>

        <input type="submit" value="Inserir" class="bt">
    </form>

    <script>
        function carregarPrecoProduto() {
            var select = document.getElementById("id_produto");
            var selectedOption = select.options[select.selectedIndex];
            var preco = selectedOption.getAttribute("data-preco");
            if (preco) {
                document.getElementById("preco_unitario").value = parseFloat(preco).toFixed(2);
                calcularTotal();
            }
        }
        
        function calcularTotal() {
            var quantidade = parseFloat(document.getElementById("quantidade").value) || 0;
            var precoUnitario = parseFloat(document.getElementById("preco_unitario").value) || 0;
            var precoTotal = quantidade * precoUnitario;
            document.getElementById("preco_total").value = precoTotal.toFixed(2);
        }
    </script>
    
    <br>
    <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
</body>
</html>
