<%-- 
    Document   : noticias-formacao
    Created on : Dec 28, 2025, 12:09:07 AM
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // Verificar se o utilizador está logado
    Integer idUtilizador = (Integer) session.getAttribute("id_utilizador");
    String primeiroNome = (String) session.getAttribute("primeiro_nome");
    String ultimoNome = (String) session.getAttribute("ultimo_nome");
    String emailUtilizador = (String) session.getAttribute("email");
    Boolean isAdmin = (Boolean) session.getAttribute("is_admin");
    
    if (isAdmin == null) {
        isAdmin = false;
    }
    
    boolean estaLogado = (idUtilizador != null);
    
    // Verificar se o utilizador já é sócio
    boolean jaSocio = false;
    String numeroSocio = null;
    String dataSocio = null;
    
    if (estaLogado) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            String dbURL = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
            String dbUser = "root";
            String dbPass = "";
            
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
            
            String sql = "SELECT numero_socio, data_inscricao FROM t_socio WHERE id_utilizador = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idUtilizador);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                jaSocio = true;
                numeroSocio = rs.getString("numero_socio");
                dataSocio = rs.getString("data_inscricao");
            }
            
        } catch (Exception e) {
            out.println("<!-- Erro ao verificar sócio: " + e.getMessage() + " -->");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
    
    // Buscar notícias da base de dados
    List<Map<String, Object>> noticias = new ArrayList<>();
    Map<String, Object> noticiaDestaque = null;
    
    Connection connNoticias = null;
    Statement stmtNoticias = null;
    ResultSet rsNoticias = null;
    
    try {
        String dbURL = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
        String dbUser = "root";
        String dbPass = "";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        connNoticias = DriverManager.getConnection(dbURL, dbUser, dbPass);
        stmtNoticias = connNoticias.createStatement();
        
        // Buscar todas as notícias ativas ordenadas por data
        rsNoticias = stmtNoticias.executeQuery(
            "SELECT * FROM t_noticias_formacao WHERE ativo = 1 ORDER BY data_publicacao DESC"
        );
        
        while (rsNoticias.next()) {
            Map<String, Object> noticia = new HashMap<>();
            noticia.put("id", rsNoticias.getInt("id_noticia"));
            noticia.put("titulo", rsNoticias.getString("titulo"));
            noticia.put("categoria", rsNoticias.getString("categoria"));
            noticia.put("resumo", rsNoticias.getString("resumo"));
            noticia.put("conteudo", rsNoticias.getString("conteudo"));
            noticia.put("icone", rsNoticias.getString("icone"));
            noticia.put("imagem_url", rsNoticias.getString("imagem_url"));
            noticia.put("data", rsNoticias.getTimestamp("data_publicacao"));
            noticia.put("autor", rsNoticias.getString("autor"));
            noticia.put("visualizacoes", rsNoticias.getInt("visualizacoes"));
            
            boolean isDestaque = rsNoticias.getInt("destaque") == 1;
            noticia.put("destaque", isDestaque);
            
            // Se for destaque e ainda não temos um, guardar
            if (isDestaque && noticiaDestaque == null) {
                noticiaDestaque = noticia;
            } else {
                noticias.add(noticia);
            }
        }
        
    } catch (Exception e) {
        out.println("<!-- Erro ao buscar notícias: " + e.getMessage() + " -->");
    } finally {
        if (rsNoticias != null) try { rsNoticias.close(); } catch (SQLException e) {}
        if (stmtNoticias != null) try { stmtNoticias.close(); } catch (SQLException e) {}
        if (connNoticias != null) try { connNoticias.close(); } catch (SQLException e) {}
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Notícias de Formação - SC Rio Tinto</title>
  <link href="css/CssNoticias-Formacao.css" rel="stylesheet" type="text/css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>
<body>
  <header id="header">
    <div class="logo-container" onclick="window.location.href='index.htm'">
      <div class="logo-icon">SC</div>
      <span>Rio Tinto</span>
    </div>
    <nav>
      <ul>
        <li><a href="index.htm">Home</a></li>
        <li><a href="noticias-formacao.jsp">Formação</a></li>        
        <li><a href="Produtos.jsp">Produtos</a></li>
        <li><a href="Bilheteria.jsp">Bilheteria</a></li>
        <li><a href="Socios front page.jsp">Sócios</a></li>
        <li><a href="Equipas.jsp">Equipas</a></li>
        <li><a href="Sobre.jsp">Sobre</a></li>
        <li>
          <% if (estaLogado) { %>
            <div class="user-dropdown">
              <button class="btn-header">
                <i class="fas fa-user-circle"></i>
                <%= primeiroNome %>
                <% if (isAdmin) { %>
                  <span class="admin-badge">ADMIN</span>
                <% } %>
                <% if (jaSocio) { %>
                  <span class="socio-badge">✓ SÓCIO</span>
                <% } %>
                <i class="fas fa-chevron-down" style="font-size: 0.8rem;"></i>
              </button>
              <div class="dropdown-menu">
                <div class="dropdown-header">
                  <div class="user-name">
                    <%= primeiroNome %> <%= ultimoNome %>
                    <% if (jaSocio) { %>
                      <span class="socio-badge">✓ SÓCIO</span>
                    <% } %>
                  </div>
                  <div class="user-email"><%= emailUtilizador %></div>
                  <% if (jaSocio) { %>
                    <div style="margin-top: 0.5rem; padding-top: 0.5rem; border-top: 1px solid rgba(255, 215, 0, 0.2);">
                      <div style="color: var(--amarelo); font-size: 0.75rem; font-weight: 600;">
                        <i class="fas fa-id-card"></i> Nº <%= numeroSocio %>
                      </div>
                    </div>
                  <% } %>
                </div>
                <a href="perfil.jsp" class="dropdown-item">
                  <i class="fas fa-user"></i>
                  Meu Perfil
                </a>
                <% if (jaSocio) { %>
                  <a href="cartao-socio.jsp" class="dropdown-item">
                    <i class="fas fa-id-card"></i>
                    Cartão de Sócio
                  </a>
                <% } else { %>
                  <a href="Socios front page.jsp" class="dropdown-item" style="background: rgba(16, 185, 129, 0.1);">
                    <i class="fas fa-user-plus"></i>
                    Tornar-me Sócio
                  </a>
                <% } %>
                <a href="pedidos.jsp" class="dropdown-item">
                  <i class="fas fa-shopping-bag"></i>
                  Meus Pedidos
                </a>
                <a href="MeusBilhetes.jsp" class="dropdown-item">
                  <i class="fas fa-ticket"></i>
                  Meus Bilhetes
                </a>
                <% if (isAdmin) { %>
                  <div class="dropdown-divider"></div>
                  <a href="admin.jsp" class="dropdown-item">
                    <i class="fas fa-crown"></i>
                    Painel Admin
                  </a>
                <% } %>
                <div class="dropdown-divider"></div>
                <a href="logout.jsp" class="dropdown-item logout">
                  <i class="fas fa-sign-out-alt"></i>
                  Terminar Sessão
                </a>
              </div>
            </div>
          <% } else { %>
            <div class="user-dropdown">
              <button class="btn-header">
                <i class="fas fa-user"></i>
                Conta
                <i class="fas fa-chevron-down" style="font-size: 0.8rem;"></i>
              </button>
              <div class="dropdown-menu">
                <a href="Login.jsp" class="dropdown-item">
                  <i class="fas fa-sign-in-alt"></i>
                  Iniciar Sessão
                </a>
                <a href="Registro.jsp" class="dropdown-item">
                  <i class="fas fa-user-plus"></i>
                  Criar Conta
                </a>
              </div>
            </div>
          <% } %>
        </li>
      </ul>
    </nav>
  </header>

  <section class="news-hero">
    <div class="news-hero-content">
      <h1>Formação <span class="highlight">Rio Tinto</span></h1>
      <p>Acompanha todas as novidades, conquistas e histórias dos nossos jovens talentos.</p>
    </div>
  </section>

  <section class="filter-section">
    <div class="filter-container">
      <div class="search-box">
        <i class="fas fa-search"></i>
        <input type="text" id="searchInput" placeholder="Pesquisar notícias...">
      </div>
      <div class="filter-buttons">
        <button class="filter-btn active" data-filter="all">Todas</button>
        <button class="filter-btn" data-filter="sub11">Sub-11</button>
        <button class="filter-btn" data-filter="sub15">Sub-15</button>
        <button class="filter-btn" data-filter="sub17">Sub-17</button>
        <button class="filter-btn" data-filter="sub19">Sub-19</button>
      </div>
    </div>
  </section>

  <section class="news-section">
    <div class="news-container">
      <% if (noticiaDestaque != null) { %>
      <div class="featured-news">
        <div class="featured-card" onclick="openModal('noticia<%= noticiaDestaque.get("id") %>')">
          <div class="featured-image" style="background: linear-gradient(135deg, rgba(255, 215, 0, 0.3), rgba(10, 10, 10, 0.5)), 
                  url('<%= noticiaDestaque.get("imagem_url") != null ? noticiaDestaque.get("imagem_url") : "" %>') center/cover; background-color: var(--cinza);">
            <span class="featured-badge">⭐ DESTAQUE</span>
            <% if (noticiaDestaque.get("imagem_url") == null) { %>
            <i class="<%= noticiaDestaque.get("icone") %>"></i>
            <% } %>
          </div>
          <div class="featured-content">
            <div class="news-meta">
              <span class="meta-item">
                <i class="fas fa-calendar"></i>
                <%= new java.text.SimpleDateFormat("dd MMMM yyyy", new java.util.Locale("pt", "PT")).format(noticiaDestaque.get("data")) %>
              </span>
              <span class="meta-item">
                <i class="<%= noticiaDestaque.get("icone") %>"></i>
                <%= ((String)noticiaDestaque.get("categoria")).toUpperCase() %>
              </span>
              <% if (noticiaDestaque.get("autor") != null) { %>
              <span class="meta-item">
                <i class="fas fa-user"></i>
                <%= noticiaDestaque.get("autor") %>
              </span>
              <% } %>
            </div>
            <h2><%= noticiaDestaque.get("titulo") %></h2>
            <p><%= noticiaDestaque.get("resumo") %></p>
            <a href="#" class="read-more-btn" onclick="event.stopPropagation(); openModal('noticia<%= noticiaDestaque.get("id") %>'); return false;">
              Ler Mais
              <i class="fas fa-arrow-right"></i>
            </a>
          </div>
        </div>
      </div>
      <% } %>

      <div class="news-grid" id="newsGrid">
        <% 
        if (noticias.size() == 0 && noticiaDestaque == null) { 
        %>
          <div style="grid-column: 1 / -1; text-align: center; padding: 3rem;">
            <i class="fas fa-newspaper" style="font-size: 4rem; color: var(--amarelo); margin-bottom: 1rem;"></i>
            <h3 style="font-size: 1.5rem; margin-bottom: 0.5rem;">Nenhuma notícia disponível</h3>
            <p style="color: #666;">Em breve teremos novidades sobre a formação!</p>
          </div>
        <% 
        } else {
          for (Map<String, Object> noticia : noticias) { 
            String categoria = (String) noticia.get("categoria");
            String badgeClass = "category-" + categoria;
        %>
        <div class="news-card" data-category="<%= categoria %>" onclick="openModal('noticia<%= noticia.get("id") %>')">
          <div class="news-image" style="background: linear-gradient(135deg, rgba(255, 215, 0, 0.2), rgba(10, 10, 10, 0.4)), 
                  url('<%= noticia.get("imagem_url") != null ? noticia.get("imagem_url") : "" %>') center/cover; background-color: var(--cinza);">
            <span class="category-badge <%= badgeClass %>"><%= categoria.toUpperCase() %></span>
            <% if (noticia.get("imagem_url") == null) { %>
            <i class="<%= noticia.get("icone") %>"></i>
            <% } %>
          </div>
          <div class="news-content">
            <h3><%= noticia.get("titulo") %></h3>
            <p class="news-excerpt"><%= noticia.get("resumo") %></p>
            <div class="news-footer">
              <span class="news-date">
                <i class="fas fa-calendar"></i>
                <%= new java.text.SimpleDateFormat("dd MMM yyyy", new java.util.Locale("pt", "PT")).format(noticia.get("data")) %>
              </span>
              <a href="#" class="news-link" onclick="event.stopPropagation(); openModal('noticia<%= noticia.get("id") %>'); return false;">
                Ler Mais <i class="fas fa-arrow-right"></i>
              </a>
            </div>
          </div>
        </div>
        <% 
          }
        }
        %>
      </div>

      <div class="no-results" id="noResults">
        <i class="fas fa-search"></i>
        <h3>Nenhuma notícia encontrada</h3>
        <p>Tenta ajustar os filtros ou pesquisar por outros termos.</p>
      </div>
    </div>
  </section>

  <div class="modal" id="newsModal">
    <div class="modal-content">
      <div class="modal-close" onclick="closeModal()">
        <i class="fas fa-times"></i>
      </div>
      <div class="modal-image" id="modalImage">
        <i class="fas fa-newspaper"></i>
      </div>
      <div class="modal-body" id="modalBody">
      </div>
    </div>
  </div>

  <footer style="background: var(--preto); color: var(--branco); padding: 3rem 2rem 2rem 2rem; text-align: center;">
    <div style="max-width: 1200px; margin: 0 auto;">
      <div style="display: flex; justify-content: center; gap: 2rem; margin-bottom: 2rem;">
        <a href="https://www.instagram.com/sportcluberiotinto/" target="_blank" style="width: 50px; height: 50px; background: var(--gold-gradient); background-size: 200% 200%; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: var(--preto); font-size: 1.3rem; transition: all 0.3s ease; text-decoration: none; animation: goldShimmer 4s ease-in-out infinite;">
          <i class="fab fa-instagram"></i>
        </a>
      </div>
      <p>&copy; 2025 SC Rio Tinto. Todos os direitos reservados.</p>
      <p>Feito com <span style="color: var(--amarelo);">💛</span> para os verdadeiros adeptos</p>
    </div>
  </footer>

  <script>
    const header = document.querySelector("header");

  window.addEventListener("scroll", () => {
    if (window.scrollY > 50) {
      header.classList.add("scrolled");
    } else {
      header.classList.remove("scrolled");
    }
  });

    const filterBtns = document.querySelectorAll('.filter-btn');
    const newsCards = document.querySelectorAll('.news-card');
    const searchInput = document.getElementById('searchInput');
    const noResults = document.getElementById('noResults');

    let activeFilter = 'all';

    filterBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        filterBtns.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        activeFilter = btn.dataset.filter;
        filterNews();
      });
    });

    searchInput.addEventListener('input', () => {
      filterNews();
    });

    function filterNews() {
      const searchTerm = searchInput.value.toLowerCase();
      let visibleCount = 0;

      newsCards.forEach(card => {
        const category = card.dataset.category;
        const title = card.querySelector('h3').textContent.toLowerCase();
        const excerpt = card.querySelector('.news-excerpt').textContent.toLowerCase();
        
        const matchesFilter = activeFilter === 'all' || category === activeFilter;
        const matchesSearch = title.includes(searchTerm) || excerpt.includes(searchTerm);

        if (matchesFilter && matchesSearch) {
          card.style.display = 'block';
          visibleCount++;
        } else {
          card.style.display = 'none';
        }
      });

      if (visibleCount === 0) {
        noResults.classList.add('active');
      } else {
        noResults.classList.remove('active');
      }
    }

    const modal = document.getElementById('newsModal');
    const modalBody = document.getElementById('modalBody');
    const modalImage = document.getElementById('modalImage');

    // DADOS DAS NOTÍCIAS - USANDO JSON SEGURO
    const newsData = {};
    
    <%
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd MMMM yyyy", new java.util.Locale("pt", "PT"));
    
    // Função para escapar strings para JavaScript
    java.lang.reflect.Method escapeJs = null;
    try {
        Class<?> clazz = Class.forName("org.apache.commons.text.StringEscapeUtils");
        escapeJs = clazz.getMethod("escapeEcmaScript", String.class);
    } catch (Exception e) {
        // Fallback manual se não tiver a biblioteca
    }
    
    if (noticiaDestaque != null) {
      String id = "noticia" + noticiaDestaque.get("id");
      String titulo = (String)noticiaDestaque.get("titulo");
      String categoria = ((String)noticiaDestaque.get("categoria")).toUpperCase();
      String icone = (String)noticiaDestaque.get("icone");
      String autor = noticiaDestaque.get("autor") != null ? (String)noticiaDestaque.get("autor") : "";
      String imagem = noticiaDestaque.get("imagem_url") != null ? (String)noticiaDestaque.get("imagem_url") : "";
      String conteudo = (String)noticiaDestaque.get("conteudo");
      String data = sdf.format(noticiaDestaque.get("data"));
      
      // Escape manual robusto
      titulo = titulo.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "").replace("\t", "\\t");
      autor = autor.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "").replace("\t", "\\t");
      conteudo = conteudo.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "").replace("\t", "\\t");
    %>
    newsData['<%= id %>'] = {
      title: '<%= titulo %>',
      date: '<%= data %>',
      category: '<%= categoria %>',
      icon: '<%= icone %>',
      author: '<%= autor %>',
      image: '<%= imagem %>',
      content: '<%= conteudo %>'
    };
    <% } %>
    
    <% 
    for (Map<String, Object> noticia : noticias) {
      String id = "noticia" + noticia.get("id");
      String titulo = (String)noticia.get("titulo");
      String categoria = ((String)noticia.get("categoria")).toUpperCase();
      String icone = (String)noticia.get("icone");
      String autor = noticia.get("autor") != null ? (String)noticia.get("autor") : "";
      String imagem = noticia.get("imagem_url") != null ? (String)noticia.get("imagem_url") : "";
      String conteudo = (String)noticia.get("conteudo");
      String data = sdf.format(noticia.get("data"));
      
      // Escape manual robusto
      titulo = titulo.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "").replace("\t", "\\t");
      autor = autor.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "").replace("\t", "\\t");
      conteudo = conteudo.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "").replace("\t", "\\t");
    %>
    newsData['<%= id %>'] = {
      title: '<%= titulo %>',
      date: '<%= data %>',
      category: '<%= categoria %>',
      icon: '<%= icone %>',
      author: '<%= autor %>',
      image: '<%= imagem %>',
      content: '<%= conteudo %>'
    };
    <% } %>

    function openModal(newsId) {
      console.log('=== DEBUG MODAL ===');
      console.log('1. ID recebido:', newsId);
      console.log('2. Todos os dados disponíveis:', newsData);
      console.log('3. Dados desta notícia:', newsData[newsId]);
      
      const news = newsData[newsId];
      
      if (!news) {
        console.error('❌ ERRO: Notícia não encontrada!');
        alert('Erro: Notícia não encontrada! ID: ' + newsId);
        return;
      }

      console.log('4. ✅ Notícia encontrada!');
      console.log('5. Título:', news.title);
      console.log('6. Conteúdo:', news.content);

      // Atualizar a imagem do modal
      if (news.image && news.image.trim() !== '') {
        modalImage.style.backgroundImage = 'linear-gradient(135deg, rgba(255, 215, 0, 0.3), rgba(10, 10, 10, 0.5)), url(\'' + news.image + '\')';
        modalImage.innerHTML = '';
        console.log('7. Imagem definida:', news.image);
      } else {
        modalImage.style.backgroundImage = 'linear-gradient(135deg, rgba(255, 215, 0, 0.3), rgba(10, 10, 10, 0.5))';
        modalImage.innerHTML = '<i class="' + news.icon + '"></i>';
        console.log('7. Ícone definido:', news.icon);
      }

      // Construir os metadados
      var metaHTML = '<div class="news-meta" style="margin-bottom: 2rem;">';
      metaHTML += '<span class="meta-item">';
      metaHTML += '<i class="fas fa-calendar"></i>';
      metaHTML += news.date;
      metaHTML += '</span>';
      metaHTML += '<span class="meta-item">';
      metaHTML += '<i class="' + news.icon + '"></i>';
      metaHTML += news.category;
      metaHTML += '</span>';
      
      if (news.author && news.author.trim() !== '') {
        metaHTML += '<span class="meta-item">';
        metaHTML += '<i class="fas fa-user"></i>';
        metaHTML += news.author;
        metaHTML += '</span>';
      }
      
      metaHTML += '</div>';

      // Converter \n em <br> para exibir quebras de linha
      var contentWithBreaks = news.content.replace(/\\n/g, '<br>');
      console.log('8. Conteúdo processado:', contentWithBreaks.substring(0, 100) + '...');

      // Atualizar o conteúdo do modal - USANDO CONCATENAÇÃO
      var finalHTML = metaHTML;
      finalHTML += '<h2 style="font-size: 2.5rem; font-weight: 800; color: var(--preto); margin-bottom: 1.5rem; line-height: 1.2;">';
      finalHTML += news.title;
      finalHTML += '</h2>';
      finalHTML += '<div style="color: #666; font-size: 1.1rem; line-height: 1.8;">';
      finalHTML += contentWithBreaks;
      finalHTML += '</div>';
      
      console.log('9. HTML final (primeiros 200 chars):', finalHTML.substring(0, 200) + '...');
      
      modalBody.innerHTML = finalHTML;
      
      console.log('10. ✅ Modal body atualizado!');
      console.log('11. Modal body innerHTML:', modalBody.innerHTML.substring(0, 200) + '...');

      // Mostrar o modal
      modal.classList.add('active');
      document.body.style.overflow = 'hidden';
      
      console.log('12. ✅ Modal aberto!');
      console.log('=== FIM DEBUG ===');
    }

    function closeModal() {
      modal.classList.remove('active');
      document.body.style.overflow = 'auto';
    }

    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        closeModal();
      }
    });

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && modal.classList.contains('active')) {
        closeModal();
      }
    });

    document.addEventListener('DOMContentLoaded', () => {
      console.log('🏆 SC Rio Tinto - Notícias de Formação carregadas!');
      console.log('💛 Força Rio Tinto! 💛');
      console.log('Dados carregados:', Object.keys(newsData).length, 'notícias');
    });
  </script>
</body>
</html>