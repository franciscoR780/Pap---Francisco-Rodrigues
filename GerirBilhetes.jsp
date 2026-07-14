<%-- 
    Document   : GerirBilhetes
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
    <title>Gerir Bilhetes</title>
    <link href="style.css" rel="stylesheet" type="text/css">
    <style>
        .badge {
            padding: 0.3rem 0.8rem;
            border-radius: 12px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-block;
        }
        .badge-reservado {
            background: #FFF3CD;
            color: #856404;
        }
        .badge-vendido {
            background: #D1ECF1;
            color: #0C5460;
        }
        .badge-validado {
            background: #D4EDDA;
            color: #155724;
        }
        .badge-cancelado {
            background: #F8D7DA;
            color: #721C24;
        }
        .tipo-normal {
            color: #007bff;
            font-weight: bold;
        }
        .tipo-socio {
            color: #28a745;
            font-weight: bold;
        }
        .tipo-estudante {
            color: #17a2b8;
            font-weight: bold;
        }
        .tipo-crianca {
            color: #ffc107;
            font-weight: bold;
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
                String id_evento = request.getParameter("id_evento");
                String id_utilizador = request.getParameter("id_utilizador");
                String nome_titular = request.getParameter("nome_titular");
                String email_titular = request.getParameter("email_titular");
                String telefone_titular = request.getParameter("telefone_titular");
                String tipo_bilhete = request.getParameter("tipo_bilhete");
                String setor = request.getParameter("setor");
                String fila = request.getParameter("fila");
                String lugar = request.getParameter("lugar");
                String preco_pago = request.getParameter("preco_pago");
                String estado_bilhete = request.getParameter("estado_bilhete");
                String metodo_pagamento = request.getParameter("metodo_pagamento");
                String observacoes = request.getParameter("observacoes");
                
                // Gerar código único para o bilhete
                String codigoBilhete = "SCRT" + System.currentTimeMillis();
                String numeroBilhete = "B" + String.format("%08d", (int)(Math.random() * 99999999));
                
                String sql = "INSERT INTO t_bilhetes (id_evento, id_utilizador, codigo_bilhete, numero_bilhete, nome_titular, email_titular, telefone_titular, tipo_bilhete, setor, fila, lugar, preco_pago, estado_bilhete, data_reserva, data_venda, metodo_pagamento, observacoes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                
                statement.setInt(1, Integer.parseInt(id_evento));
                statement.setObject(2, id_utilizador.isEmpty() ? null : Integer.parseInt(id_utilizador));
                statement.setString(3, codigoBilhete);
                statement.setString(4, numeroBilhete);
                statement.setString(5, nome_titular);
                statement.setString(6, email_titular.isEmpty() ? null : email_titular);
                statement.setString(7, telefone_titular.isEmpty() ? null : telefone_titular);
                statement.setString(8, tipo_bilhete);
                statement.setString(9, setor);
                statement.setString(10, fila.isEmpty() ? null : fila);
                statement.setString(11, lugar.isEmpty() ? null : lugar);
                statement.setDouble(12, Double.parseDouble(preco_pago));
                statement.setString(13, estado_bilhete);
                statement.setObject(14, estado_bilhete.equals("vendido") ? new java.sql.Timestamp(System.currentTimeMillis()) : null);
                statement.setString(15, metodo_pagamento.isEmpty() ? null : metodo_pagamento);
                statement.setString(16, observacoes.isEmpty() ? null : observacoes);
                
                int rowsInserted = statement.executeUpdate();
                
                // Atualizar contador de bilhetes vendidos no evento
                if (rowsInserted > 0 && estado_bilhete.equals("vendido")) {
                    PreparedStatement updateEvento = conn.prepareStatement(
                        "UPDATE t_eventos SET bilhetes_vendidos = bilhetes_vendidos + 1 WHERE id_evento = ?"
                    );
                    updateEvento.setInt(1, Integer.parseInt(id_evento));
                    updateEvento.executeUpdate();
                    updateEvento.close();
                }
                
                out.println(rowsInserted > 0 ? "<h2>Bilhete inserido com sucesso! Código: " + codigoBilhete + "</h2>" : "Erro na inserção.");
                
                statement.close();
            } 
            else if ("apagar".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                
                // Buscar info do bilhete antes de apagar
                PreparedStatement getInfo = conn.prepareStatement(
                    "SELECT id_evento, estado_bilhete FROM t_bilhetes WHERE id_bilhete=?"
                );
                getInfo.setInt(1, id);
                ResultSet rsInfo = getInfo.executeQuery();
                
                if (rsInfo.next()) {
                    int idEvento = rsInfo.getInt("id_evento");
                    String estado = rsInfo.getString("estado_bilhete");
                    
                    // Apagar bilhete
                    String sql = "DELETE FROM t_bilhetes WHERE id_bilhete=?";
                    PreparedStatement stm = conn.prepareStatement(sql);
                    stm.setInt(1, id);
                    
                    int rowsDeleted = stm.executeUpdate();
                    
                    // Atualizar contador se era vendido
                    if (rowsDeleted > 0 && estado.equals("vendido")) {
                        PreparedStatement updateEvento = conn.prepareStatement(
                            "UPDATE t_eventos SET bilhetes_vendidos = bilhetes_vendidos - 1 WHERE id_evento = ?"
                        );
                        updateEvento.setInt(1, idEvento);
                        updateEvento.executeUpdate();
                        updateEvento.close();
                    }
                    
                    out.println(rowsDeleted > 0 ? "<h2>Bilhete apagado com sucesso.</h2>" :
                                                   "Não existe nenhum bilhete com esse id: " + id);
                    
                    stm.close();
                }
                rsInfo.close();
                getInfo.close();
            }
            else if ("atualizar_estado".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String novoEstado = request.getParameter("novo_estado");
                String estadoAntigo = request.getParameter("estado_antigo");
                
                String sql = "UPDATE t_bilhetes SET estado_bilhete=?";
                
                // Se mudar para validado, atualizar data_validacao
                if (novoEstado.equals("validado")) {
                    sql += ", data_validacao=NOW()";
                }
                // Se mudar para vendido, atualizar data_venda
                else if (novoEstado.equals("vendido") && estadoAntigo.equals("reservado")) {
                    sql += ", data_venda=NOW()";
                }
                
                sql += " WHERE id_bilhete=?";
                
                PreparedStatement stm = conn.prepareStatement(sql);
                stm.setString(1, novoEstado);
                stm.setInt(2, id);
                
                int rowsUpdated = stm.executeUpdate();
                
                // Atualizar contador do evento
                if (rowsUpdated > 0) {
                    PreparedStatement getEvento = conn.prepareStatement(
                        "SELECT id_evento FROM t_bilhetes WHERE id_bilhete=?"
                    );
                    getEvento.setInt(1, id);
                    ResultSet rsEvento = getEvento.executeQuery();
                    
                    if (rsEvento.next()) {
                        int idEvento = rsEvento.getInt("id_evento");
                        
                        // Se mudou de reservado para vendido
                        if (estadoAntigo.equals("reservado") && novoEstado.equals("vendido")) {
                            PreparedStatement updateEvento = conn.prepareStatement(
                                "UPDATE t_eventos SET bilhetes_vendidos = bilhetes_vendidos + 1 WHERE id_evento = ?"
                            );
                            updateEvento.setInt(1, idEvento);
                            updateEvento.executeUpdate();
                            updateEvento.close();
                        }
                        // Se cancelou um bilhete vendido
                        else if (estadoAntigo.equals("vendido") && novoEstado.equals("cancelado")) {
                            PreparedStatement updateEvento = conn.prepareStatement(
                                "UPDATE t_eventos SET bilhetes_vendidos = bilhetes_vendidos - 1 WHERE id_evento = ?"
                            );
                            updateEvento.setInt(1, idEvento);
                            updateEvento.executeUpdate();
                            updateEvento.close();
                        }
                    }
                    rsEvento.close();
                    getEvento.close();
                }
                
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
    <h1>Gerir Bilhetes</h1>

    <!-- ========================= -->
    <!--      TABELA EM PRIMEIRO   -->
    <!-- ========================= -->

    <table border="1">
        <tr>
            <th>Id</th>
            <th>Código</th>
            <th>Evento</th>
            <th>Titular</th>
            <th>Tipo</th>
            <th>Setor/Lugar</th>
            <th>Preço</th>
            <th>Estado</th>
            <th>Pagamento</th>
            <th>Datas</th>
            <th>Ações</th>
        </tr>

<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
        
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(
            "SELECT b.*, " +
            "e.nome_evento, " +
            "e.data_evento, " +
            "CONCAT(u.primeiro_nome, ' ', u.ultimo_nome) as nome_utilizador " +
            "FROM t_bilhetes b " +
            "INNER JOIN t_eventos e ON b.id_evento = e.id_evento " +
            "LEFT JOIN t_utilizadores u ON b.id_utilizador = u.id_utilizador " +
            "ORDER BY b.id_bilhete DESC"
        );
        
        while (rs.next()) {
            String estado = rs.getString("estado_bilhete");
            String badgeClass = "badge-" + estado;
            String tipo = rs.getString("tipo_bilhete");
            String tipoClass = "tipo-" + tipo;
            String fila = rs.getString("fila");
            String lugar = rs.getString("lugar");
%>
        <tr>
            <td><%= rs.getInt("id_bilhete") %></td>
            <td>
                <strong><%= rs.getString("codigo_bilhete") %></strong><br/>
                <small style="color: #666;"><%= rs.getString("numero_bilhete") %></small>
            </td>
            <td>
                <strong><%= rs.getString("nome_evento") %></strong><br/>
                <small style="color: #666;"><%= rs.getTimestamp("data_evento") %></small>
            </td>
            <td>
                <%= rs.getString("nome_titular") %><br/>
                <small style="color: #666;">
                    <%= rs.getString("email_titular") != null ? rs.getString("email_titular") : "" %><br/>
                    <%= rs.getString("telefone_titular") != null ? rs.getString("telefone_titular") : "" %>
                </small>
                <% if (rs.getString("nome_utilizador") != null) { %>
                    <br/><small style="color: #28a745;"><strong>Utilizador:</strong> <%= rs.getString("nome_utilizador") %></small>
                <% } %>
            </td>
            <td>
                <span class="<%= tipoClass %>">
                    <%= tipo.toUpperCase() %>
                </span>
            </td>
            <td>
                <%= rs.getString("setor") %><br/>
                <% if (fila != null && lugar != null) { %>
                    <small style="color: #666;">Fila <%= fila %> - Lugar <%= lugar %></small>
                <% } else { %>
                    <small style="color: #999;">Lugar Livre</small>
                <% } %>
            </td>
            <td><%= String.format("%.2f€", rs.getDouble("preco_pago")) %></td>
            <td>
                <span class="badge <%= badgeClass %>">
                    <%= estado.toUpperCase() %>
                </span>
                
                <!-- Form para atualizar estado -->
                <form method="post" style="display:inline; margin-top: 5px;">
                    <input type="hidden" name="acao" value="atualizar_estado">
                    <input type="hidden" name="id" value="<%= rs.getInt("id_bilhete") %>">
                    <input type="hidden" name="estado_antigo" value="<%= estado %>">
                    <select name="novo_estado" style="font-size: 0.8rem;">
                        <option value="reservado" <%= estado.equals("reservado") ? "selected" : "" %>>Reservado</option>
                        <option value="vendido" <%= estado.equals("vendido") ? "selected" : "" %>>Vendido</option>
                        <option value="validado" <%= estado.equals("validado") ? "selected" : "" %>>Validado</option>
                        <option value="cancelado" <%= estado.equals("cancelado") ? "selected" : "" %>>Cancelado</option>
                    </select>
                    <input type="submit" value="Atualizar" style="font-size: 0.8rem;">
                </form>
            </td>
            <td>
                <%= rs.getString("metodo_pagamento") != null ? rs.getString("metodo_pagamento").toUpperCase() : "-" %><br/>
                <small style="color: #666;">
                    <%= rs.getString("referencia_pagamento") != null ? rs.getString("referencia_pagamento") : "" %>
                </small>
            </td>
            <td style="font-size: 0.75rem;">
                <strong>Reserva:</strong> <%= rs.getTimestamp("data_reserva") != null ? rs.getTimestamp("data_reserva") : "-" %><br/>
                <strong>Venda:</strong> <%= rs.getTimestamp("data_venda") != null ? rs.getTimestamp("data_venda") : "-" %><br/>
                <strong>Validação:</strong> <%= rs.getTimestamp("data_validacao") != null ? rs.getTimestamp("data_validacao") : "-" %>
            </td>

            <td>
                <form method="post" style="display:inline;">
                    <input type="hidden" name="acao" value="apagar">
                    <input type="hidden" name="id" value="<%= rs.getInt("id_bilhete") %>">
                    <input type="submit" value="Apagar" onclick="return confirm('Tem certeza que deseja apagar este bilhete?');">
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

    <h2>Inserir Novo Bilhete</h2>
    <form method="post">
        <input type="hidden" name="acao" value="inserir">

        Evento:
        <select name="id_evento" required id="eventoSelect" onchange="carregarPrecos()">
            <option value="">Selecione o evento...</option>
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery(
                        "SELECT id_evento, nome_evento, data_evento, preco_normal, preco_socio, preco_estudante, preco_crianca " +
                        "FROM t_eventos WHERE estado_evento IN ('agendado', 'venda_aberta') ORDER BY data_evento"
                    );
                    
                    while (rs.next()) {
            %>
                        <option value="<%= rs.getInt("id_evento") %>" 
                                data-normal="<%= rs.getDouble("preco_normal") %>"
                                data-socio="<%= rs.getDouble("preco_socio") %>"
                                data-estudante="<%= rs.getDouble("preco_estudante") %>"
                                data-crianca="<%= rs.getDouble("preco_crianca") %>">
                            <%= rs.getString("nome_evento") %> - <%= rs.getTimestamp("data_evento") %>
                        </option>
            <%
                    }
                    rs.close();
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<option value=''>Erro ao carregar eventos</option>");
                }
            %>
        </select><br>

        Utilizador (opcional):
        <select name="id_utilizador">
            <option value="">Sem utilizador registado</option>
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery(
                        "SELECT id_utilizador, primeiro_nome, ultimo_nome, email FROM t_utilizadores ORDER BY primeiro_nome"
                    );
                    
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
                } catch (Exception e) {}
            %>
        </select><br>

        Nome do Titular:
        <input type="text" name="nome_titular" required placeholder="Nome completo"><br>

        Email do Titular:
        <input type="email" name="email_titular" placeholder="email@exemplo.com"><br>

        Telefone do Titular:
        <input type="text" name="telefone_titular" placeholder="912345678"><br>

        Tipo de Bilhete:
        <select name="tipo_bilhete" required id="tipoBilhete" onchange="atualizarPreco()">
            <option value="">Selecione...</option>
            <option value="normal">Normal</option>
            <option value="socio">Sócio</option>
            <option value="estudante">Estudante</option>
            <option value="crianca">Criança</option>
        </select><br>

        Setor:
        <input type="text" name="setor" value="Geral" required><br>

        Fila (opcional):
        <input type="text" name="fila" placeholder="Ex: A"><br>

        Lugar (opcional):
        <input type="text" name="lugar" placeholder="Ex: 15"><br>

        Preço:
        <input type="number" step="0.01" name="preco_pago" id="precoPago" required><br>

        Estado:
        <select name="estado_bilhete" required>
            <option value="reservado">Reservado</option>
            <option value="vendido" selected>Vendido</option>
            <option value="validado">Validado</option>
            <option value="cancelado">Cancelado</option>
        </select><br>

        Método de Pagamento:
        <select name="metodo_pagamento">
            <option value="">Selecione...</option>
            <option value="multibanco">Multibanco</option>
            <option value="mbway">MBWay</option>
            <option value="cartao">Cartão</option>
            <option value="paypal">PayPal</option>
            <option value="dinheiro">Dinheiro</option>
        </select><br>

        Observações:
        <textarea name="observacoes" rows="3" cols="40" placeholder="Observações adicionais (opcional)"></textarea><br>

        <input type="submit" value="Inserir Bilhete">
    </form>

    <script>
        function atualizarPreco() {
            var eventoSelect = document.getElementById('eventoSelect');
            var tipoSelect = document.getElementById('tipoBilhete');
            var precoInput = document.getElementById('precoPago');
            
            if (eventoSelect.value && tipoSelect.value) {
                var opcaoSelecionada = eventoSelect.options[eventoSelect.selectedIndex];
                var tipo = tipoSelect.value;
                var preco = 0;
                
                switch(tipo) {
                    case 'normal':
                        preco = opcaoSelecionada.getAttribute('data-normal');
                        break;
                    case 'socio':
                        preco = opcaoSelecionada.getAttribute('data-socio');
                        break;
                    case 'estudante':
                        preco = opcaoSelecionada.getAttribute('data-estudante');
                        break;
                    case 'crianca':
                        preco = opcaoSelecionada.getAttribute('data-crianca');
                        break;
                }
                
                precoInput.value = parseFloat(preco).toFixed(2);
            }
        }
        
        function carregarPrecos() {
            atualizarPreco();
        }
    </script>
    
    <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
</body>
</html>