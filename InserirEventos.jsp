<%-- 
    Document   : InserirEventos
    Created on : Dec 23, 2025
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
            <meta http-equiv="refresh" content="2;url=admin.jsp">
        <% } %>
        <title>Inserção de Eventos</title>
    </head>
    <body>
        <h1>Inserir Evento</h1>
        <%
        if (request.getMethod().equals("POST")) {
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
            
            String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
            String username = "root";
            String password = "";
            
            try { 
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(url, username, password);
                
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
                if (rowsInserted > 0) {
                    out.println("<h2>Evento inserido com sucesso.</h2>");
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
            <form method="post" action="InserirEventos.jsp">
                <label>Nome do Evento: 
                    <input type="text" name="nome_evento" required placeholder="Ex: SC Rio Tinto vs FC Porto B" style="width: 300px;">
                </label><br/><br/>

                <label>Equipa Casa: 
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
                    </select>
                </label><br/><br/>

                <label>Equipa Fora (opcional): 
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
                    </select>
                </label><br/><br/>

                <label>Local do Evento: 
                    <input type="text" name="local_evento" value="Estádio SC Rio Tinto" required style="width: 300px;">
                </label><br/><br/>

                <label>Data do Evento: 
                    <input type="datetime-local" name="data_evento" required>
                </label><br/><br/>

                <label>Data Abertura Venda: 
                    <input type="datetime-local" name="data_abertura_venda" required>
                </label><br/><br/>

                <label>Data Fecho Venda: 
                    <input type="datetime-local" name="data_fecho_venda" required>
                </label><br/><br/>

                <label>Competição: 
                    <input type="text" name="competicao" placeholder="Ex: Campeonato Distrital">
                </label><br/><br/>

                <label>Jornada: 
                    <input type="text" name="jornada" placeholder="Ex: 15ª Jornada">
                </label><br/><br/>

                <label>Capacidade Total: 
                    <input type="number" name="capacidade_total" value="5000" required>
                </label><br/><br/>

                <h3>Preços dos Bilhetes</h3>

                <label>Preço Normal: 
                    <input type="number" step="0.01" name="preco_normal" value="10.00" required>
                </label><br/><br/>

                <label>Preço Sócio: 
                    <input type="number" step="0.01" name="preco_socio" value="5.00" required>
                </label><br/><br/>

                <label>Preço Estudante: 
                    <input type="number" step="0.01" name="preco_estudante" value="7.00" required>
                </label><br/><br/>

                <label>Preço Criança: 
                    <input type="number" step="0.01" name="preco_crianca" value="5.00" required>
                </label><br/><br/>

                <label>Estado: 
                    <select name="estado_evento" required>
                        <option value="agendado" selected>Agendado</option>
                        <option value="venda_aberta">Venda Aberta</option>
                        <option value="esgotado">Esgotado</option>
                        <option value="concluido">Concluído</option>
                        <option value="cancelado">Cancelado</option>
                    </select>
                </label><br/><br/>

                <label>Descrição: 
                    <textarea name="descricao" rows="4" cols="50" placeholder="Descrição do evento (opcional)"></textarea>
                </label><br/><br/>

                <label>Observações: 
                    <textarea name="observacoes" rows="4" cols="50" placeholder="Observações adicionais (opcional)"></textarea>
                </label><br/><br/>
                
                <input type="submit" value="Inserir Evento" class="bt">
            </form>
        <%
        }
        %>
        <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
    </body>
</html>
