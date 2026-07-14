<%-- 
    Document   : InserirJogadores
    Created on : 11/11/2025, 11:24:04
    Author     : Aluno
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
        <title>Inserção de Jogadores</title>
    </head>
    <body>
        <h1>Inserir Jogadores</h1>
        <%
        if (request.getMethod().equals("POST")) {
            String id_equipa = request.getParameter("id_equipa");
            String primeiro_nome = request.getParameter("primeiro_nome");
            String ultimo_nome = request.getParameter("ultimo_nome");
            String numero_camisola = request.getParameter("numero_camisola");
            String posicao = request.getParameter("posicao");
            String foto_url = request.getParameter("foto_url");
            
            String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
            String username = "root";
            String password = "";
            
            try { 
                Class.forName("com.mysql.jdbc.Driver");
                Connection conn = DriverManager.getConnection(url, username, password);
                
                String sql = "INSERT INTO t_jogadores (id_equipa, primeiro_nome, ultimo_nome, numero_camisola, posicao, foto_url) VALUES (?, ?, ?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                
                statement.setString(1, id_equipa);
                statement.setString(2, primeiro_nome);
                statement.setString(3, ultimo_nome);
                statement.setString(4, numero_camisola);
                statement.setString(5, posicao);
                statement.setString(6, foto_url);
                
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
            <form method="post" action="InserirJogadores.jsp">
                <label>Equipa: 
                <select name="id_equipa">
                    <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            Connection connEquipas = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");

                            Statement stmtEquipas = connEquipas.createStatement();
                            ResultSet rsEquipas = stmtEquipas.executeQuery("SELECT id_equipa, nome_equipa FROM t_equipas");

                            while (rsEquipas.next()) {
                    %>
                                <option value="<%= rsEquipas.getInt("id_equipa") %>"><%= rsEquipas.getString("nome_equipa") %></option>
                    <%
                            }

                            rsEquipas.close();
                            stmtEquipas.close();
                            connEquipas.close();
                        } catch (Exception e) {
                            out.println("Erro ao carregar equipas: " + e.getMessage());
                        }
                    %>
                        </select>
                    </label><br/><br/>
                <label>Primeiro Nome: <input type="text" name="primeiro_nome" size="20" 
                                        placeholder="Coloque o primeiro nome"></label><br/><br/>
                <label>Último Nome: <input type="text" name="ultimo_nome" size="20" 
                                        placeholder="Coloque o último nome"></label><br/><br/>
                <label>Número Camisola: <input type="text" name="numero_camisola" size="20" 
                                        placeholder="Coloque o número da camisola"></label><br/><br/>
                <label>Posição: <input type="text" name="posicao" size="20" 
                                        placeholder="Coloque a posição"></label><br/><br/>
                <label>Foto URL: <input type="text" name="foto_url" size="20" 
                                        placeholder="Coloque o URL da foto"></label><br/><br/>
                <input type="submit" value="Inserir" class="bt">
            </form>
        <%
        }
        %>
        <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
    </body>
</html>