<%-- 
    Document   : GerirEncomendas
    Created on : Dec 15, 2025, 1:52:35 AM
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" 
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gerir Encomendas</title>
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
        .badge-processando {
            background: #D1ECF1;
            color: #0C5460;
        }
        .badge-enviado {
            background: #D4EDDA;
            color: #155724;
        }
        .badge-entregue {
            background: #C3E6CB;
            color: #155724;
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
                String morada_envio = request.getParameter("morada_envio");
                String metodo_pagamento = request.getParameter("metodo_pagamento");
                String estado = request.getParameter("estado");
                String valor_total = request.getParameter("valor_total");
                String numero_encomenda = request.getParameter("numero_encomenda");
                String codigo_rastreio = request.getParameter("codigo_rastreio");
                String observacoes = request.getParameter("observacoes");
                String desconto = request.getParameter("desconto");
                String taxa_envio = request.getParameter("taxa_envio");
                
                String sql = "INSERT INTO t_encomendas (id_utilizador, morada_envio, metodo_pagamento, estado, valor_total, numero_encomenda, codigo_rastreio, observacoes, desconto, taxa_envio) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                
                statement.setInt(1, Integer.parseInt(id_utilizador));
                statement.setString(2, morada_envio);
                statement.setString(3, metodo_pagamento);
                statement.setString(4, estado);
                statement.setDouble(5, Double.parseDouble(valor_total));
                statement.setString(6, numero_encomenda.isEmpty() ? null : numero_encomenda);
                statement.setString(7, codigo_rastreio.isEmpty() ? null : codigo_rastreio);
                statement.setString(8, observacoes.isEmpty() ? null : observacoes);
                statement.setDouble(9, desconto.isEmpty() ? 0.0 : Double.parseDouble(desconto));
                statement.setDouble(10, taxa_envio.isEmpty() ? 0.0 : Double.parseDouble(taxa_envio));
                
                int rowsInserted = statement.executeUpdate();
                out.println(rowsInserted > 0 ? "<h2>Registo inserido com sucesso.</h2>" : "Erro na inserção.");
                
                statement.close();
            } 
            else if ("apagar".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                
                String sql = "DELETE FROM t_encomendas WHERE id_encomenda=?";
                PreparedStatement stm = conn.prepareStatement(sql);
                stm.setInt(1, id);
                
                int rowsDeleted = stm.executeUpdate();
                out.println(rowsDeleted > 0 ? "<h2>Registo apagado com sucesso.</h2>" :
                                               "Não existe nenhum registo com esse id: " + id);
                
                stm.close();
            }
            else if ("atualizar_estado".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String novoEstado = request.getParameter("novo_estado");
                
                String sql = "UPDATE t_encomendas SET estado=? WHERE id_encomenda=?";
                PreparedStatement stm = conn.prepareStatement(sql);
                stm.setString(1, novoEstado);
                stm.setInt(2, id);
                
                int rowsUpdated = stm.executeUpdate();
                out.println(rowsUpdated > 0 ? "<h2>Estado atualizado com sucesso.</h2>" : "Erro ao atualizar estado.");
                
                stm.close();
            }
            else if ("atualizar_rastreio".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String codigoRastreio = request.getParameter("codigo_rastreio");
                
                String sql = "UPDATE t_encomendas SET codigo_rastreio=? WHERE id_encomenda=?";
                PreparedStatement stm = conn.prepareStatement(sql);
                stm.setString(1, codigoRastreio.isEmpty() ? null : codigoRastreio);
                stm.setInt(2, id);
                
                int rowsUpdated = stm.executeUpdate();
                out.println(rowsUpdated > 0 ? "<h2>Código de rastreio atualizado com sucesso.</h2>" : "Erro ao atualizar código.");
                
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
    <h1>Gerir Encomendas</h1>

    <!-- ========================= -->
    <!--      TABELA EM PRIMEIRO   -->
    <!-- ========================= -->

    <table border="1">
        <tr>
            <th>Id</th>
            <th>Nº Encomenda</th>
            <th>Utilizador</th>
            <th>Data</th>
            <th>Morada Envio</th>
            <th>Método Pag.</th>
            <th>Estado</th>
            <th>Código Rastreio</th>
            <th>Valor Total</th>
            <th>Desconto</th>
            <th>Taxa Envio</th>
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
            "SELECT e.*, " +
            "CONCAT(u.primeiro_nome, ' ', u.ultimo_nome) as nome_utilizador, " +
            "u.email " +
            "FROM t_encomendas e " +
            "INNER JOIN t_utilizadores u ON e.id_utilizador = u.id_utilizador " +
            "ORDER BY e.id_encomenda DESC"
        );
        
        while (rs.next()) {
            String estado = rs.getString("estado");
            String badgeClass = "badge-" + estado;
            String numeroEnc = rs.getString("numero_encomenda");
            String codRastreio = rs.getString("codigo_rastreio");
            String obs = rs.getString("observacoes");
%>
        <tr>
            <td><%= rs.getInt("id_encomenda") %></td>
            <td><%= numeroEnc != null ? numeroEnc : "-" %></td>
            <td>
                <%= rs.getString("nome_utilizador") %><br/>
                <small style="color: #666;"><%= rs.getString("email") %></small>
            </td>
            <td><%= rs.getTimestamp("data_encomenda") %></td>
            <td><%= rs.getString("morada_envio") %></td>
            <td><%= rs.getString("metodo_pagamento") %></td>
            <td>
                <span class="badge <%= badgeClass %>">
                    <%= estado.toUpperCase() %>
                </span>
                
                <!-- Form para atualizar estado -->
                <form method="post" style="display:inline; margin-top: 5px;">
                    <input type="hidden" name="acao" value="atualizar_estado">
                    <input type="hidden" name="id" value="<%= rs.getInt("id_encomenda") %>">
                    <select name="novo_estado" style="font-size: 0.8rem;">
                        <option value="pendente" <%= estado.equals("pendente") ? "selected" : "" %>>Pendente</option>
                        <option value="processando" <%= estado.equals("processando") ? "selected" : "" %>>Processando</option>
                        <option value="enviado" <%= estado.equals("enviado") ? "selected" : "" %>>Enviado</option>
                        <option value="entregue" <%= estado.equals("entregue") ? "selected" : "" %>>Entregue</option>
                    </select>
                    <input type="submit" value="Atualizar" style="font-size: 0.8rem;">
                </form>
            </td>
            <td>
                <%= codRastreio != null ? codRastreio : "-" %>
                <!-- Form para atualizar código de rastreio -->
                <form method="post" style="display:inline; margin-top: 5px;">
                    <input type="hidden" name="acao" value="atualizar_rastreio">
                    <input type="hidden" name="id" value="<%= rs.getInt("id_encomenda") %>">
                    <input type="text" name="codigo_rastreio" placeholder="Código" style="font-size: 0.8rem; width: 100px;" value="<%= codRastreio != null ? codRastreio : "" %>">
                    <input type="submit" value="Atualizar" style="font-size: 0.8rem;">
                </form>
            </td>
            <td><%= String.format("%.2f€", rs.getDouble("valor_total")) %></td>
            <td><%= String.format("%.2f€", rs.getDouble("desconto")) %></td>
            <td><%= String.format("%.2f€", rs.getDouble("taxa_envio")) %></td>
            <td><%= obs != null ? obs : "-" %></td>

            <td>
                <form method="post" style="display:inline;">
                    <input type="hidden" name="acao" value="apagar">
                    <input type="hidden" name="id" value="<%= rs.getInt("id_encomenda") %>">
                    <input type="submit" value="Apagar" onclick="return confirm('Tem certeza que deseja apagar esta encomenda?');">
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

    <h2>Inserir Nova Encomenda</h2>
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
                    ResultSet rs = stmt.executeQuery("SELECT id_utilizador, primeiro_nome, ultimo_nome, email FROM t_utilizadores ORDER BY primeiro_nome");
                    
                    while (rs.next()) {
                        int idUser = rs.getInt("id_utilizador");
                        String primeiroNome = rs.getString("primeiro_nome");
                        String ultimoNome = rs.getString("ultimo_nome");
                        String nomeCompleto = primeiroNome + " " + ultimoNome;
                        String email = rs.getString("email");
            %>
                        <option value="<%= idUser %>"><%= nomeCompleto %> (<%= email %>)</option>
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

        Número da Encomenda:
        <input type="text" name="numero_encomenda" placeholder="Ex: ENC2025001"><br>

        Morada de Envio:
        <textarea name="morada_envio" rows="3" cols="40" required></textarea><br>

        Método Pagamento:
        <select name="metodo_pagamento" required>
            <option value="">Selecione...</option>
            <option value="multibanco">Multibanco</option>
            <option value="mbway">MBWay</option>
            <option value="cartao">Cartão</option>
            <option value="paypal">PayPal</option>
        </select><br>

        Estado:
        <select name="estado" required>
            <option value="pendente" selected>Pendente</option>
            <option value="processando">Processando</option>
            <option value="enviado">Enviado</option>
            <option value="entregue">Entregue</option>
        </select><br>

        Código de Rastreio:
        <input type="text" name="codigo_rastreio" placeholder="Ex: PT123456789BR"><br>

        Valor Total:
        <input type="number" step="0.01" name="valor_total" required><br>

        Desconto:
        <input type="number" step="0.01" name="desconto" value="0.00"><br>

        Taxa de Envio:
        <input type="number" step="0.01" name="taxa_envio" value="0.00"><br>

        Observações:
        <textarea name="observacoes" rows="3" cols="40" placeholder="Observações adicionais (opcional)"></textarea><br>

        <input type="submit" value="Inserir">
    </form>

    
    <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
</body>
</html>