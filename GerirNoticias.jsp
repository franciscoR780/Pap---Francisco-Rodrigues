<%-- 
    Document   : GerirNoticias
    Created on : Dec 28, 2025, 12:27:14 AM
    Author     : Francisco
--%>

<%-- 
    Document   : GerirNoticias
    Created on : Dec 28, 2025
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" 
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gerir Notícias de Formação</title>
    <link href="style.css" rel="stylesheet" type="text/css">
    <style>
        .badge {
            padding: 0.3rem 0.8rem;
            border-radius: 12px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-block;
        }
        .badge-sub11 {
            background: #D1E7FF;
            color: #004085;
        }
        .badge-sub13 {
            background: #D4EDDA;
            color: #155724;
        }
        .badge-sub15 {
            background: #FFF3CD;
            color: #856404;
        }
        .badge-sub17 {
            background: #F8D7DA;
            color: #721C24;
        }
        .badge-sub19 {
            background: #E7D4F5;
            color: #5A189A;
        }
        .badge-geral {
            background: #E2E3E5;
            color: #383D41;
        }
        .badge-destaque {
            background: linear-gradient(135deg, #FFD700 0%, #FFA000 100%);
            color: #000;
            font-weight: 700;
            box-shadow: 0 2px 10px rgba(255, 215, 0, 0.3);
        }
        .badge-ativo {
            background: #D4EDDA;
            color: #155724;
        }
        .badge-inativo {
            background: #F8D7DA;
            color: #721C24;
        }
        table {
            font-size: 0.9rem;
        }
        td, th {
            padding: 8px;
        }
        .resumo-cell {
            max-width: 300px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .edit-form {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin: 10px 0;
            border: 2px solid #FFD700;
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
                String titulo = request.getParameter("titulo");
                String categoria = request.getParameter("categoria");
                String resumo = request.getParameter("resumo");
                String conteudo = request.getParameter("conteudo");
                String imagem_url = request.getParameter("imagem_url");
                String icone = request.getParameter("icone");
                String destaque = request.getParameter("destaque");
                String autor = request.getParameter("autor");
                String ativo = request.getParameter("ativo");
                String data_publicacao = request.getParameter("data_publicacao");
                
                String sql = "INSERT INTO t_noticias_formacao (titulo, categoria, resumo, conteudo, imagem_url, icone, destaque, autor, ativo, data_publicacao) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                
                statement.setString(1, titulo);
                statement.setString(2, categoria);
                statement.setString(3, resumo.isEmpty() ? null : resumo);
                statement.setString(4, conteudo);
                statement.setString(5, imagem_url.isEmpty() ? null : imagem_url);
                statement.setString(6, icone);
                statement.setBoolean(7, destaque != null && destaque.equals("1"));
                statement.setString(8, autor.isEmpty() ? "SC Rio Tinto" : autor);
                statement.setBoolean(9, ativo != null && ativo.equals("1"));
                statement.setString(10, data_publicacao);
                
                int rowsInserted = statement.executeUpdate();
                
                out.println(rowsInserted > 0 ? "<h2>Notícia inserida com sucesso!</h2>" : "Erro na inserção.");
                
                statement.close();
            } 
            else if ("apagar".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                
                String sql = "DELETE FROM t_noticias_formacao WHERE id_noticia=?";
                PreparedStatement stm = conn.prepareStatement(sql);
                stm.setInt(1, id);
                
                int rowsDeleted = stm.executeUpdate();
                
                out.println(rowsDeleted > 0 ? "<h2>Notícia apagada com sucesso.</h2>" :
                                               "Não existe nenhuma notícia com esse id: " + id);
                
                stm.close();
            }
            else if ("atualizar".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String titulo = request.getParameter("titulo");
                String categoria = request.getParameter("categoria");
                String resumo = request.getParameter("resumo");
                String conteudo = request.getParameter("conteudo");
                String imagem_url = request.getParameter("imagem_url");
                String icone = request.getParameter("icone");
                String destaque = request.getParameter("destaque");
                String autor = request.getParameter("autor");
                String ativo = request.getParameter("ativo");
                
                String sql = "UPDATE t_noticias_formacao SET titulo=?, categoria=?, resumo=?, conteudo=?, imagem_url=?, icone=?, destaque=?, autor=?, ativo=? WHERE id_noticia=?";
                PreparedStatement stm = conn.prepareStatement(sql);
                
                stm.setString(1, titulo);
                stm.setString(2, categoria);
                stm.setString(3, resumo.isEmpty() ? null : resumo);
                stm.setString(4, conteudo);
                stm.setString(5, imagem_url.isEmpty() ? null : imagem_url);
                stm.setString(6, icone);
                stm.setBoolean(7, destaque != null && destaque.equals("1"));
                stm.setString(8, autor.isEmpty() ? "SC Rio Tinto" : autor);
                stm.setBoolean(9, ativo != null && ativo.equals("1"));
                stm.setInt(10, id);
                
                int rowsUpdated = stm.executeUpdate();
                
                out.println(rowsUpdated > 0 ? "<h2>Notícia atualizada com sucesso.</h2>" : "Erro ao atualizar notícia.");
                
                stm.close();
            }
            else if ("toggle_destaque".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                
                String sql = "UPDATE t_noticias_formacao SET destaque = NOT destaque WHERE id_noticia=?";
                PreparedStatement stm = conn.prepareStatement(sql);
                stm.setInt(1, id);
                
                int rowsUpdated = stm.executeUpdate();
                
                out.println(rowsUpdated > 0 ? "<h2>Status de destaque atualizado.</h2>" : "Erro ao atualizar.");
                
                stm.close();
            }
            else if ("toggle_ativo".equals(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                
                String sql = "UPDATE t_noticias_formacao SET ativo = NOT ativo WHERE id_noticia=?";
                PreparedStatement stm = conn.prepareStatement(sql);
                stm.setInt(1, id);
                
                int rowsUpdated = stm.executeUpdate();
                
                out.println(rowsUpdated > 0 ? "<h2>Status ativo/inativo atualizado.</h2>" : "Erro ao atualizar.");
                
                stm.close();
            }
            
            conn.close();
        } catch (Exception e) {
            out.println("Ocorreu um erro: " + e.getMessage());
        }
    }
    
    // Verificar se está em modo de edição
    String editId = request.getParameter("edit");
%>

</head>

<body>
    <h1>Gerir Notícias de Formação</h1>

    <!-- ========================= -->
    <!--      TABELA EM PRIMEIRO   -->
    <!-- ========================= -->

    <table border="1">
        <tr>
            <th>Id</th>
            <th>Título</th>
            <th>Categoria</th>
            <th>Resumo</th>
            <th>Status</th>
            <th>Visualizações</th>
            <th>Autor</th>
            <th>Data Publicação</th>
            <th>Ações</th>
        </tr>

<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
        
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(
            "SELECT * FROM t_noticias_formacao ORDER BY id_noticia DESC"
        );
        
        while (rs.next()) {
            String categoria = rs.getString("categoria");
            String badgeClass = "badge-" + categoria;
            boolean destaque = rs.getBoolean("destaque");
            boolean ativo = rs.getBoolean("ativo");
            int idNoticia = rs.getInt("id_noticia");
            
            // Se está em modo de edição para esta notícia, mostrar formulário
            if (editId != null && editId.equals(String.valueOf(idNoticia))) {
%>
        <tr>
            <td colspan="9" class="edit-form">
                <h3>✏️ Editar Notícia #<%= idNoticia %></h3>
                <form method="post">
                    <input type="hidden" name="acao" value="atualizar">
                    <input type="hidden" name="id" value="<%= idNoticia %>">
                    
                    <label><strong>Título:</strong><br/>
                        <input type="text" name="titulo" required style="width: 90%;" value="<%= rs.getString("titulo") %>">
                    </label><br/><br/>
                    
                    <label><strong>Categoria:</strong>
                        <select name="categoria" required>
                            <option value="sub11" <%= categoria.equals("sub11") ? "selected" : "" %>>Sub-11</option>
                            <option value="sub13" <%= categoria.equals("sub13") ? "selected" : "" %>>Sub-13</option>
                            <option value="sub15" <%= categoria.equals("sub15") ? "selected" : "" %>>Sub-15</option>
                            <option value="sub17" <%= categoria.equals("sub17") ? "selected" : "" %>>Sub-17</option>
                            <option value="sub19" <%= categoria.equals("sub19") ? "selected" : "" %>>Sub-19</option>
                            <option value="geral" <%= categoria.equals("geral") ? "selected" : "" %>>Geral</option>
                        </select>
                    </label><br/><br/>
                    
                    <label><strong>Resumo:</strong><br/>
                        <textarea name="resumo" rows="3" style="width: 90%;"><%= rs.getString("resumo") != null ? rs.getString("resumo") : "" %></textarea>
                    </label><br/><br/>
                    
                    <label><strong>Conteúdo (HTML):</strong><br/>
                        <textarea name="conteudo" rows="10" required style="width: 90%;"><%= rs.getString("conteudo") %></textarea>
                    </label><br/><br/>
                    
                    <label><strong>URL Imagem:</strong>
                        <input type="text" name="imagem_url" style="width: 60%;" value="<%= rs.getString("imagem_url") != null ? rs.getString("imagem_url") : "" %>">
                    </label><br/><br/>
                    
                    <label><strong>Ícone:</strong>
                        <select name="icone" required>
                            <option value="fas fa-newspaper" <%= rs.getString("icone").equals("fas fa-newspaper") ? "selected" : "" %>>📰 Newspaper</option>
                            <option value="fas fa-futbol" <%= rs.getString("icone").equals("fas fa-futbol") ? "selected" : "" %>>⚽ Futebol</option>
                            <option value="fas fa-trophy" <%= rs.getString("icone").equals("fas fa-trophy") ? "selected" : "" %>>🏆 Troféu</option>
                            <option value="fas fa-medal" <%= rs.getString("icone").equals("fas fa-medal") ? "selected" : "" %>>🏅 Medalha</option>
                            <option value="fas fa-star" <%= rs.getString("icone").equals("fas fa-star") ? "selected" : "" %>>⭐ Estrela</option>
                            <option value="fas fa-fire" <%= rs.getString("icone").equals("fas fa-fire") ? "selected" : "" %>>🔥 Fogo</option>
                            <option value="fas fa-users" <%= rs.getString("icone").equals("fas fa-users") ? "selected" : "" %>>👥 Utilizadores</option>
                        </select>
                    </label><br/><br/>
                    
                    <label><strong>Autor:</strong>
                        <input type="text" name="autor" style="width: 300px;" value="<%= rs.getString("autor") != null ? rs.getString("autor") : "" %>">
                    </label><br/><br/>
                    
                    <label>
                        <input type="checkbox" name="destaque" value="1" <%= destaque ? "checked" : "" %>>
                        <strong>Marcar como DESTAQUE</strong>
                    </label><br/>
                    
                    <label>
                        <input type="checkbox" name="ativo" value="1" <%= ativo ? "checked" : "" %>>
                        <strong>Notícia ATIVA</strong>
                    </label><br/><br/>
                    
                    <input type="submit" value="💾 Guardar Alterações" class="bt">
                    <a href="GerirNoticias.jsp" class="bt" style="background: #dc3545; text-decoration: none; color: white; padding: 8px 15px; border-radius: 5px; display: inline-block;">❌ Cancelar</a>
                </form>
            </td>
        </tr>
<%
            } else {
                // Modo normal de listagem
%>
        <tr>
            <td><%= idNoticia %></td>
            <td>
                <strong><%= rs.getString("titulo") %></strong>
                <% if (destaque) { %>
                    <br/><span class="badge badge-destaque">⭐ DESTAQUE</span>
                <% } %>
            </td>
            <td>
                <span class="badge <%= badgeClass %>">
                    <%= categoria.toUpperCase() %>
                </span>
            </td>
            <td class="resumo-cell">
                <%= rs.getString("resumo") != null ? rs.getString("resumo") : "-" %>
            </td>
            <td>
                <span class="badge <%= ativo ? "badge-ativo" : "badge-inativo" %>">
                    <%= ativo ? "ATIVO" : "INATIVO" %>
                </span>
                <br/><br/>
                <!-- Toggle Ativo/Inativo -->
                <form method="post" style="display:inline;">
                    <input type="hidden" name="acao" value="toggle_ativo">
                    <input type="hidden" name="id" value="<%= idNoticia %>">
                    <input type="submit" value="<%= ativo ? "❌ Desativar" : "✅ Ativar" %>" style="font-size: 0.8rem;">
                </form>
                <br/>
                <!-- Toggle Destaque -->
                <form method="post" style="display:inline;">
                    <input type="hidden" name="acao" value="toggle_destaque">
                    <input type="hidden" name="id" value="<%= idNoticia %>">
                    <input type="submit" value="<%= destaque ? "🌟 Remover Destaque" : "⭐ Marcar Destaque" %>" style="font-size: 0.8rem;">
                </form>
            </td>
            <td style="text-align: center;"><%= rs.getInt("visualizacoes") %></td>
            <td><%= rs.getString("autor") != null ? rs.getString("autor") : "-" %></td>
            <td><%= rs.getTimestamp("data_publicacao") %></td>
            <td>
                <a href="GerirNoticias.jsp?edit=<%= idNoticia %>" class="bt" style="text-decoration: none;">✏️ Editar</a>
                <br/><br/>
                <form method="post" style="display:inline;">
                    <input type="hidden" name="acao" value="apagar">
                    <input type="hidden" name="id" value="<%= idNoticia %>">
                    <input type="submit" value="🗑️ Apagar" onclick="return confirm('Tem certeza que deseja apagar esta notícia?');">
                </form>
            </td>
        </tr>
<%
            }
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

    <h2>➕ Inserir Nova Notícia</h2>
    <form method="post">
        <input type="hidden" name="acao" value="inserir">

        <label>Título: 
            <input type="text" name="titulo" required placeholder="Título da notícia" style="width: 500px;">
        </label><br/><br/>

        <label>Categoria: 
            <select name="categoria" required>
                <option value="">Selecione...</option>
                <option value="sub11">Sub-11</option>
                <option value="sub13">Sub-13</option>
                <option value="sub15">Sub-15</option>
                <option value="sub17">Sub-17</option>
                <option value="sub19">Sub-19</option>
                <option value="geral">Geral</option>
            </select>
        </label><br/><br/>

        <label>Resumo: 
            <textarea name="resumo" rows="3" cols="70" placeholder="Resumo curto para exibir nos cards"></textarea>
        </label><br/><br/>

        <label>Conteúdo (HTML): 
            <textarea name="conteudo" rows="12" cols="70" required placeholder="Conteúdo completo da notícia em HTML"></textarea>
        </label><br/><br/>

        <label>URL da Imagem: 
            <input type="text" name="imagem_url" placeholder="https://exemplo.com/imagem.jpg" style="width: 500px;">
        </label><br/><br/>

        <label>Ícone FontAwesome: 
            <select name="icone" required>
                <option value="fas fa-newspaper">📰 Newspaper (Padrão)</option>
                <option value="fas fa-futbol">⚽ Futebol</option>
                <option value="fas fa-trophy">🏆 Troféu</option>
                <option value="fas fa-medal">🏅 Medalha</option>
                <option value="fas fa-star">⭐ Estrela</option>
                <option value="fas fa-fire">🔥 Fogo</option>
                <option value="fas fa-users">👥 Utilizadores</option>
                <option value="fas fa-user-plus">➕ Novo Utilizador</option>
            </select>
        </label><br/><br/>

        <label>Autor: 
            <input type="text" name="autor" value="SC Rio Tinto" style="width: 300px;">
        </label><br/><br/>

        <label>Data de Publicação: 
            <input type="datetime-local" name="data_publicacao" required 
                   value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(new java.util.Date()) %>">
        </label><br/><br/>

        <label>
            <input type="checkbox" name="destaque" value="1">
            Marcar como DESTAQUE
        </label><br/><br/>

        <label>
            <input type="checkbox" name="ativo" value="1" checked>
            Notícia ATIVA
        </label><br/><br/>

        <input type="submit" value="Inserir Notícia">
    </form>
    
    <br/>
    <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
</body>
</html>