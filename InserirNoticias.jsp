<%-- 
    Document   : InserirNoticias
    Created on : Dec 28, 2025, 12:26:49 AM
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
        <title>Inserção de Notícias</title>
    </head>
    <body>
        <h1>Inserir Notícia de Formação</h1>
        <%
        if (request.getMethod().equals("POST")) {
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
            
            String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
            String username = "root";
            String password = "";
            
            try { 
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(url, username, password);
                
                String sql = "INSERT INTO t_noticias_formacao (titulo, categoria, resumo, conteudo, imagem_url, icone, destaque, autor, ativo, data_publicacao) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                
                statement.setString(1, titulo);
                statement.setString(2, categoria);
                statement.setString(3, resumo.isEmpty() ? null : resumo);
                statement.setString(4, conteudo);
                statement.setString(5, imagem_url.isEmpty() ? null : imagem_url);
                statement.setString(6, icone);
                statement.setBoolean(7, destaque != null && destaque.equals("1"));
                statement.setString(8, autor.isEmpty() ? null : autor);
                statement.setBoolean(9, ativo != null && ativo.equals("1"));
                statement.setString(10, data_publicacao);
                
                int rowsInserted = statement.executeUpdate();
                
                if (rowsInserted > 0) {
                    out.println("<h2>Notícia inserida com sucesso!</h2>");
                    out.println("<p><strong>Título:</strong> " + titulo + "</p>");
                    out.println("<p><strong>Categoria:</strong> " + categoria.toUpperCase() + "</p>");
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
            <form method="post" action="InserirNoticias.jsp">
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

                <label>Resumo (breve descrição): 
                    <textarea name="resumo" rows="3" cols="70" placeholder="Resumo curto para exibir nos cards"></textarea>
                </label><br/><br/>

                <label>Conteúdo (HTML completo): 
                    <textarea name="conteudo" rows="15" cols="70" required placeholder="Conteúdo completo da notícia em HTML (use tags <p>, <strong>, <br>, etc.)"></textarea>
                </label><br/><br/>

                <label>URL da Imagem (opcional): 
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
                        <option value="fas fa-calendar">📅 Calendário</option>
                        <option value="fas fa-heart">❤️ Coração</option>
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
                    Marcar como DESTAQUE (aparece em primeiro)
                </label><br/><br/>

                <label>
                    <input type="checkbox" name="ativo" value="1" checked>
                    Notícia ATIVA (visível no site)
                </label><br/><br/>
                
                <input type="submit" value="Inserir Notícia" class="bt">
            </form>

            <br/>
            <div style="background: #FFF3CD; padding: 15px; border-radius: 8px; border-left: 4px solid #FFD700;">
                <strong>💡 Dica para o conteúdo HTML:</strong>
                <p>Use tags HTML básicas para formatar o texto:</p>
                <ul>
                    <li><code>&lt;p&gt;...&lt;/p&gt;</code> - Parágrafos</li>
                    <li><code>&lt;strong&gt;...&lt;/strong&gt;</code> - Texto em negrito</li>
                    <li><code>&lt;br&gt;</code> - Quebra de linha</li>
                    <li><code>&lt;ul&gt;&lt;li&gt;...&lt;/li&gt;&lt;/ul&gt;</code> - Listas</li>
                </ul>
            </div>
        <%
        }
        %>
        <br/>
        <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
    </body>
</html>
