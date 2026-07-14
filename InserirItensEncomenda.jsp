<%-- 
    Document   : InserirItensEncomenda
    Created on : Dec 15, 2025, 1:59:23 PM
    Author     : Francisco
--%>

<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link href="style.css" rel="stylesheet" type="text/css">
        <%
        if (request.getMethod().equals("POST")) {  %>
            <meta http-equiv="refresh" content="2;url=admin.jsp">
        <% } %>
        <title>Inserção de Itens de Encomenda</title>
        <style>
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
    </head>
    <body>
        <h1>Inserir Itens de Encomenda</h1>
        <%
        if (request.getMethod().equals("POST")) {
            String id_encomenda = request.getParameter("id_encomenda");
            String id_produto = request.getParameter("id_produto");
            String quantidade = request.getParameter("quantidade");
            String preco_unitario = request.getParameter("preco_unitario");
            String preco_total = request.getParameter("preco_total");
            
            String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
            String username = "root";
            String password = "";
            
            try { 
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(url, username, password);
                
                String sql = "INSERT INTO t_itens_encomenda (id_encomenda, id_produto, quantidade, preco_unitario, preco_total) VALUES (?, ?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                
                statement.setInt(1, Integer.parseInt(id_encomenda));
                statement.setInt(2, Integer.parseInt(id_produto));
                statement.setInt(3, Integer.parseInt(quantidade));
                statement.setDouble(4, Double.parseDouble(preco_unitario));
                statement.setDouble(5, Double.parseDouble(preco_total));
                
                int rowsInserted = statement.executeUpdate();
                if (rowsInserted > 0) {
                    out.println("<div class='success-message'><h2>✓ Item de encomenda inserido com sucesso!</h2></div>");
                } else {
                    out.println("<div class='error-message'>✗ Erro na inserção.</div>");
                }
                
                statement.close();
                conn.close();
                
            } catch (SQLException e) {
                out.println("<div class='error-message'>✗ Erro SQL: " + e.getMessage() + "</div>");
            } catch (NumberFormatException e) {
                out.println("<div class='error-message'>✗ Erro: Valores numéricos inválidos.</div>");
            } catch (Exception e) {
                out.println("<div class='error-message'>✗ Ocorreu um erro: " + e.getMessage() + "</div>");
            }
        }
        else
        {
        %>
            <form method="post" action="InserirItensEncomenda.jsp">
                <label>Encomenda: 
                    <select name="id_encomenda" id="id_encomenda" required>
                        <option value="">Selecione a encomenda...</option>
                        <%
                            String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
                            String username = "root";
                            String password = "";
                            
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                Connection conn = DriverManager.getConnection(url, username, password);
                                Statement stmt = conn.createStatement();
                                ResultSet rs = stmt.executeQuery(
                                    "SELECT t_encomendas.id_encomenda, t_encomendas.id_utilizador, t_encomendas.data_encomenda, t_encomendas.estado, " +
                                    "CONCAT(t_utilizadores.primeiro_nome, ' ', t_utilizadores.ultimo_nome) as nome_utilizador " +
                                    "FROM t_encomendas " +
                                    "INNER JOIN t_utilizadores ON t_encomendas.id_utilizador = t_utilizadores.id_utilizador " +
                                    "ORDER BY t_encomendas.id_encomenda DESC"
                                );
                                
                                while (rs.next()) {
                                    int idEnc = rs.getInt("id_encomenda");
                                    int idUser = rs.getInt("id_utilizador");
                                    String nomeUser = rs.getString("nome_utilizador");
                                    String dataEnc = rs.getString("data_encomenda");
                                    String estado = rs.getString("estado");
                        %>
                                    <option value="<%= idEnc %>">
                                        #<%= idEnc %> - <%= nomeUser %> - <%= dataEnc %> (<%= estado %>)
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
                    </select>
                </label><br/><br/>
                
                <label>Produto: 
                    <select name="id_produto" id="id_produto" required onchange="carregarPrecoProduto()">
                        <option value="">Selecione o produto...</option>
                        <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                Connection conn = DriverManager.getConnection(url, username, password);
                                Statement stmt = conn.createStatement();
                                ResultSet rs = stmt.executeQuery("SELECT id_produto, nome_produto, preco FROM t_produtos ORDER BY nome_produto");
                                
                                while (rs.next()) {
                                    int idProd = rs.getInt("id_produto");
                                    String nomeProd = rs.getString("nome_produto");
                                    double precoProd = rs.getDouble("preco");
                        %>
                                    <option value="<%= idProd %>" data-preco="<%= precoProd %>">
                                        <%= nomeProd %> - <%= String.format("%.2f€", precoProd) %>
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
                    </select>
                </label><br/><br/>
                
                <label>Quantidade: 
                    <input type="number" name="quantidade" id="quantidade" min="1" required 
                           placeholder="Ex: 2" onchange="calcularTotal()">
                </label><br/><br/>
                
                <label>Preço Unitário: 
                    <input type="number" step="0.01" name="preco_unitario" id="preco_unitario" required 
                           placeholder="0.00" onchange="calcularTotal()">
                </label><br/><br/>
                
                <label>Preço Total: 
                    <input type="number" step="0.01" name="preco_total" id="preco_total" required 
                           placeholder="0.00" readonly style="background: #f0f0f0;">
                </label><br/><br/>
                
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
        <%
        }
        %>
        <br/>
        <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
    </body>
</html>