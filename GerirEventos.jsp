<%-- 
    Document   : GerirEventos
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
    <title>Gerir Eventos</title>
    <link href="style.css" rel="stylesheet" type="text/css">
    <style>
        .badge {
            padding: 0.3rem 0.8rem;
            border-radius: 12px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-block;
        }
        .badge-agendado {
            background: #FFF3CD;
            color: #856404;
        }
        .badge-venda_aberta {
            background: #D1ECF1;
            color: #0C5460;
        }
        .badge-esgotado {
            background: #F8D7DA;
            color: #721C24;
        }
        .badge-concluido {
            background: #C3E6CB;
            color: #155724;
        }
        .badge-cancelado {
            background: #E2E3E5;
            color: #383D41;
        }
        table {
            font-size: 0.9rem;
        }
        td, th {
            padding: 8px;
        }
        .preco-box {
            background: #f8f9fa;
            padding: 5px;
            border-radius: 4px;
            font-size: 0.85rem;
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
                String id_equipa_casa = request.getParameter("id_equipa_casa");
                String id_equipa_fora = request.getParameter("id_equipa_fora");
                String nome_evento = request.getParameter("nome_evento");
                String descricao = request.getParameter("descricao");
                String local_evento = request.getParameter("local_evento");
                String data_evento = request.getParameter("data_evento");
                String data_abertura_venda = request.getParameter("data_abertura_venda");
                String data_fecho_venda = request.getParameter("data_fecho_venda");
                String competicao = request.getParameter("competicao");
                String jornada = request.getParameter("jornada");
                String capacidade_total = request.getParameter("capacidade_total");
                String preco_normal = request.getParameter("preco_normal");
                String preco_socio = request.getParameter("preco_socio");
                String preco_estudante = request.getParameter("preco_estudante");
                String preco_crianca = request.getParameter("preco_crianca");
                String estado_evento = request.getParameter("estado_evento");
                String observacoes = request.getParameter("observacoes");
                
                String sql = "INSERT INTO t_eventos (id_equipa_casa, id_equipa_fora, nome_evento, descricao, local_evento, data_evento, data_abertura_venda, data_fecho_venda, competicao, jornada, capacidade_total, preco_normal, preco_socio, preco_estudante, preco_crianca, estado_evento, observacoes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                
                statement.setInt(1, Integer.parseInt(id_equipa_casa));
                statement.setObject(2, id_equipa_fora.isEmpty() ? null : Integer.parseInt(id_equipa_fora));
                statement.setString(3, nome_evento);
                statement.setString(4, descricao.isEmpty() ? null : descricao);
                statement.setString(5, local_evento);
                statement.setString(6, data_evento);
                statement.setString(7, data_abertura_venda);
                statement.setString(8, data_fecho_venda);
                statement.setString(9, competicao.isEmpty() ? null : competicao);
                statement.setString(10, jornada.isEmpty() ? null : jornada);
                statement.setInt(11, Integer.parseInt(capacidade_total));
                statement.setDouble(12, Double.parseDouble(preco_normal));
                statement.setDouble(13, Double.parseDouble(preco_socio));
                statement.setDouble(14, Double.parseDouble(preco_estudante));
                statement.setDouble(15, Double.parseDouble(preco_crianca));
                statement.setString(16, estado_evento);
                statement.setString(17, observacoes.isEmpty() ? null : observacoes);
                
                int rowsInserted = statement.executeUpdate();
                out.println(rowsInserted > 0 ? "<h2>Evento inserido com sucesso.</h2>" : "Erro na inserção.");
                
                statement.close();
            } 
            else if ("apagar".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                
                String sql = "DELETE FROM t_eventos WHERE id_evento=?";
                PreparedStatement stm = conn.prepareStatement(sql);
                stm.setInt(1, id);
                
                int rowsDeleted = stm.executeUpdate();
                out.println(rowsDeleted > 0 ? "<h2>Evento apagado com sucesso.</h2>" :
                                               "Não existe nenhum evento com esse id: " + id);
                
                stm.close();
            }
            else if ("atualizar_estado".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String novoEstado = request.getParameter("novo_estado");
                
                String sql = "UPDATE t_eventos SET estado_evento=? WHERE id_evento=?";
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
    <h1>Gerir Eventos de Bilheteira</h1>

    <!-- ========================= -->
    <!--      TABELA EM PRIMEIRO   -->
    <!-- ========================= -->

    <table border="1">
        <tr>
            <th>Id</th>
            <th>Nome do Evento</th>
            <th>Equipas</th>
            <th>Data do Evento</th>
            <th>Local</th>
            <th>Competição</th>
            <th>Preços</th>
            <th>Bilhetes</th>
            <th>Estado</th>
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
            "ec.nome_equipa AS equipa_casa, " +
            "ef.nome_equipa AS equipa_fora " +
            "FROM t_eventos e " +
            "INNER JOIN t_equipas ec ON e.id_equipa_casa = ec.id_equipa " +
            "LEFT JOIN t_equipas ef ON e.id_equipa_fora = ef.id_equipa " +
            "ORDER BY e.data_evento DESC"
        );
        
        while (rs.next()) {
            String estado = rs.getString("estado_evento");
            String badgeClass = "badge-" + estado;
            int vendidos = rs.getInt("bilhetes_vendidos");
            int capacidade = rs.getInt("capacidade_total");
            int disponiveis = capacidade - vendidos;
%>
        <tr>
            <td><%= rs.getInt("id_evento") %></td>
            <td>
                <strong><%= rs.getString("nome_evento") %></strong><br/>
                <small style="color: #666;">
                    <%= rs.getString("competicao") != null ? rs.getString("competicao") : "" %>
                    <%= rs.getString("jornada") != null ? " - " + rs.getString("jornada") : "" %>
                </small>
            </td>
            <td>
                <%= rs.getString("equipa_casa") %><br/>
                <small style="color: #666;">
                    vs <%= rs.getString("equipa_fora") != null ? rs.getString("equipa_fora") : "A definir" %>
                </small>
            </td>
            <td><%= rs.getTimestamp("data_evento") %></td>
            <td><%= rs.getString("local_evento") %></td>
            <td><%= rs.getString("competicao") != null ? rs.getString("competicao") : "-" %></td>
            <td class="preco-box">
                <strong>Normal:</strong> <%= String.format("%.2f€", rs.getDouble("preco_normal")) %><br/>
                <strong>Sócio:</strong> <%= String.format("%.2f€", rs.getDouble("preco_socio")) %><br/>
                <strong>Estudante:</strong> <%= String.format("%.2f€", rs.getDouble("preco_estudante")) %><br/>
                <strong>Criança:</strong> <%= String.format("%.2f€", rs.getDouble("preco_crianca")) %>
            </td>
            <td>
                <strong><%= vendidos %></strong> / <%= capacidade %><br/>
                <small style="color: <%= disponiveis > 0 ? "green" : "red" %>;">
                    <%= disponiveis %> disponíveis
                </small>
            </td>
            <td>
                <span class="badge <%= badgeClass %>">
                    <%= estado.toUpperCase() %>
                </span>
                
                <!-- Form para atualizar estado -->
                <form method="post" style="display:inline; margin-top: 5px;">
                    <input type="hidden" name="acao" value="atualizar_estado">
                    <input type="hidden" name="id" value="<%= rs.getInt("id_evento") %>">
                    <select name="novo_estado" style="font-size: 0.8rem;">
                        <option value="agendado" <%= estado.equals("agendado") ? "selected" : "" %>>Agendado</option>
                        <option value="venda_aberta" <%= estado.equals("venda_aberta") ? "selected" : "" %>>Venda Aberta</option>
                        <option value="esgotado" <%= estado.equals("esgotado") ? "selected" : "" %>>Esgotado</option>
                        <option value="concluido" <%= estado.equals("concluido") ? "selected" : "" %>>Concluído</option>
                        <option value="cancelado" <%= estado.equals("cancelado") ? "selected" : "" %>>Cancelado</option>
                    </select>
                    <input type="submit" value="Atualizar" style="font-size: 0.8rem;">
                </form>
            </td>

            <td>
                <form method="post" style="display:inline;">
                    <input type="hidden" name="acao" value="apagar">
                    <input type="hidden" name="id" value="<%= rs.getInt("id_evento") %>">
                    <input type="submit" value="Apagar" onclick="return confirm('Tem certeza que deseja apagar este evento?');">
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

    <h2>Inserir Novo Evento</h2>
    <form method="post">
        <input type="hidden" name="acao" value="inserir">

        Nome do Evento:
        <input type="text" name="nome_evento" required placeholder="Ex: SC Rio Tinto vs FC Porto B"><br>

        Equipa Casa:
        <select name="id_equipa_casa" required>
            <option value="">Selecione...</option>
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT id_equipa, nome_equipa FROM t_equipas ORDER BY nome_equipa");
                    
                    while (rs.next()) {
            %>
                        <option value="<%= rs.getInt("id_equipa") %>"><%= rs.getString("nome_equipa") %></option>
            <%
                    }
                    rs.close();
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<option value=''>Erro ao carregar equipas</option>");
                }
            %>
        </select><br>

        Equipa Fora (opcional):
        <select name="id_equipa_fora">
            <option value="">Nenhuma / A definir</option>
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT id_equipa, nome_equipa FROM t_equipas ORDER BY nome_equipa");
                    
                    while (rs.next()) {
            %>
                        <option value="<%= rs.getInt("id_equipa") %>"><%= rs.getString("nome_equipa") %></option>
            <%
                    }
                    rs.close();
                    stmt.close();
                    conn.close();
                } catch (Exception e) {}
            %>
        </select><br>

        Local do Evento:
        <input type="text" name="local_evento" value="Estádio SC Rio Tinto" required><br>

        Data do Evento:
        <input type="datetime-local" name="data_evento" required><br>

        Data Abertura Venda:
        <input type="datetime-local" name="data_abertura_venda" required><br>

        Data Fecho Venda:
        <input type="datetime-local" name="data_fecho_venda" required><br>

        Competição:
        <input type="text" name="competicao" placeholder="Ex: Campeonato Distrital"><br>

        Jornada:
        <input type="text" name="jornada" placeholder="Ex: 15ª Jornada"><br>

        Capacidade Total:
        <input type="number" name="capacidade_total" value="5000" required><br>

        <h3>Preços dos Bilhetes</h3>
        
        Preço Normal:
        <input type="number" step="0.01" name="preco_normal" value="10.00" required><br>

        Preço Sócio:
        <input type="number" step="0.01" name="preco_socio" value="5.00" required><br>

        Preço Estudante:
        <input type="number" step="0.01" name="preco_estudante" value="7.00" required><br>

        Preço Criança:
        <input type="number" step="0.01" name="preco_crianca" value="5.00" required><br>

        Estado:
        <select name="estado_evento" required>
            <option value="agendado" selected>Agendado</option>
            <option value="venda_aberta">Venda Aberta</option>
            <option value="esgotado">Esgotado</option>
            <option value="concluido">Concluído</option>
            <option value="cancelado">Cancelado</option>
        </select><br>

        Descrição:
        <textarea name="descricao" rows="3" cols="40" placeholder="Descrição do evento (opcional)"></textarea><br>

        Observações:
        <textarea name="observacoes" rows="3" cols="40" placeholder="Observações adicionais (opcional)"></textarea><br>

        <input type="submit" value="Inserir Evento">
    </form>

    
    <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
</body>
</html>
