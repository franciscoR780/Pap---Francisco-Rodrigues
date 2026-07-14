<%-- 
    Document   : index.jsp
    Created on : Dec 11, 2025, 12:12:17 AM
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
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
            // Configuração da base de dados - AJUSTAR CONFORME A SUA CONFIGURAÇÃO
            String dbURL = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
            String dbUser = "root";
            String dbPass = "";
            
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
            
            // Verificar se existe registo na tabela de sócios
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
%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SC Rio Tinto - Official Store</title>
  <link href="css/CssIndex.css" rel="stylesheet" type="text/css">
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
        <li><a href="#home">Home</a></li>
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

  <section class="hero" id="home">
    <div class="hero-content">
      <% if (jaSocio) { %>
        <div class="hero-badge">✓ Sócio Nº <%= numeroSocio %></div>
        <h1>Bem-vindo, <span class="highlight"><%= primeiroNome %></span>!</h1>
        <p>Obrigado por fazeres parte da família SC Rio Tinto. Continua a apoiar o teu clube com orgulho e paixão!</p>
      <% } else if (estaLogado) { %>
        <h1>SC <span class="highlight">Rio Tinto</span></h1>
        <p>Bem-vindo de volta, <%= primeiroNome %>! Continua a apoiar o teu clube com estilo.</p>
      <% } else { %>
        
        <h1>SC <span class="highlight">Rio Tinto</span></h1>
        <p>Mais do que um clube, uma família. Veste as cores da paixão e da história que nos une há gerações.</p>
      <% } %>
      <div class="hero-buttons">
        <a href="Produtos.jsp" class="btn-hero btn-primary">
          <i class="fas fa-tshirt"></i>
          Ver Produtos
        </a>
        <% if (!jaSocio) { %>
          <a href="Socios front page.jsp" class="btn-hero btn-secondary">
            <i class="fas fa-star"></i>
            Tornar-me Sócio
          </a>
        <% } else { %>
          <a href="cartao-socio.jsp" class="btn-hero btn-secondary">
            <i class="fas fa-id-card"></i>
            Meu Cartão
          </a>
        <% } %>
      </div>
    </div>
  </section>
      
  <section class="features-section" id="sobre">
    <div class="features-container">
      <div class="section-title">
        <h2>Orgulho de ser Rio Tinto</h2>
        <p>Descobre o que nos torna únicos e porque somos mais do que um simples clube de futebol.</p>
      </div>
      
      <div class="features-grid">
        <div class="feature-card">
          <div class="feature-icon">
            <i class="fas fa-star"></i>
          </div>
          <h3>Qualidade Premium</h3>
          <p>Produtos oficiais com os mais altos padrões de qualidade, criados especialmente para os verdadeiros adeptos do clube.</p>
        </div>
        
        <div class="feature-card">
          <div class="feature-icon">
            <i class="fas fa-users"></i>
          </div>
          <h3>Comunidade Unida</h3>
          <p>Uma família que se estende muito além do campo, unindo gerações através do amor pelas cores amarelo e preto.</p>
        </div>
        
        <div class="feature-card">
          <div class="feature-icon">
            <i class="fas fa-trophy"></i>
          </div>
          <h3>Tradição Vencedora</h3>
          <p>Mais de 100 anos de história, paixão e conquistas que nos tornam um dos clubes mais respeitados da região.</p>
        </div>
        
        <div class="feature-card">
          <div class="feature-icon">
            <i class="fas fa-shipping-fast"></i>
          </div>
          <h3>Entrega Rápida</h3>
          <p>Envios rápidos e seguros para todo o país. Recebe o teu equipamento em casa com total comodidade.</p>
        </div>
        
        <div class="feature-card">
          <div class="feature-icon">
            <i class="fas fa-shield-alt"></i>
          </div>
          <h3>Garantia Total</h3>
          <p>Todos os produtos têm garantia oficial. Compra com confiança na loja oficial do SC Rio Tinto.</p>
        </div>
        
        <div class="feature-card">
          <div class="feature-icon">
            <i class="fas fa-heart"></i>
          </div>
          <h3>Paixão Inabalável</h3>
          <p>Cada produto representa o nosso amor pelo clube e pelo desporto que nos une a todos como uma verdadeira família.</p>
        </div>
      </div>
    </div>
  </section>

  <section class="products-preview" id="produtos">
    <div class="products-container">
      <div class="section-title">
        <h2>Produtos em Destaque</h2>
        <p>Descobre a nossa seleção premium de produtos oficiais para esta temporada</p>
      </div>
      
      <div class="products-grid">
        <div class="product-card">
          <span class="product-badge novo">Novo</span>
          <div class="product-image">
            <img src="images/camisola 25 26.png" alt="Camisola Principal 25/26">
          </div>
          <div class="product-info">
            <span class="product-category">🏆 Equipamento Oficial</span>
            <div class="product-name">Camisola Principal 25/26</div>
            <div class="product-features">
              <span class="product-feature-tag">
                <i class="fas fa-check-circle"></i>
                Oficial
              </span>
              <span class="product-feature-tag">
                <i class="fas fa-tshirt"></i>
                Premium
              </span>
            </div>
            <div class="product-price-wrapper">
              <div class="product-price">€25.00</div>
              <span class="product-price-label">IVA Incluído</span>
            </div>
            <button class="product-btn" onclick="window.location.href='Produtos.jsp'">
              <i class="fas fa-shopping-cart"></i>
              <span>Ver Detalhes</span>
            </button>
          </div>
        </div>
        
        <div class="product-card">
          <span class="product-badge">Destaque</span>
          <div class="product-image">
            <img src="images/Bone SCRT.png" alt="Boné Oficial SC">
          </div>
          <div class="product-info">
            <span class="product-category">🧢 Acessórios</span>
            <div class="product-name">Boné Oficial SC</div>
            <div class="product-features">
              <span class="product-feature-tag">
                <i class="fas fa-check-circle"></i>
                Oficial
              </span>
              <span class="product-feature-tag">
                <i class="fas fa-sun"></i>
                UV Protection
              </span>
            </div>
            <div class="product-price-wrapper">
              <div class="product-price">€19.99</div>
              <span class="product-price-label">IVA Incluído</span>
            </div>
            <button class="product-btn" onclick="window.location.href='Produtos.jsp'">
              <i class="fas fa-shopping-cart"></i>
              <span>Ver Detalhes</span>
            </button>
          </div>
        </div>
      </div>
      
      <div class="products-cta">
        <a href="Produtos.jsp" class="btn-hero btn-primary">
          <i class="fas fa-shopping-cart"></i>
          Ver Todos os Produtos
        </a>
      </div>
    </div>
  </section>

  <section class="cta-section">
    <div class="cta-content">
      <h2>Fica a saber mais sobre a nossa história!</h2>
      <p>Aqui saberás quando o SC Rio Tinto foi fundado, os seus principais objetivos, trofeus e conquistas!</p>
      <a href="Sobre.jsp" class="btn-hero btn-primary">
        <i class="fas fa-book"></i>
        Clica Aqui!
      </a>
    </div>
  </section>

  <footer>
        <div class="footer-content">
            <div class="social-links">
      <a href="https://www.instagram.com/sportcluberiotinto/" title="Instagram"><i class="fab fa-instagram"></i></a>
    </div>
            <p>&copy; 2025 SC Rio Tinto. Todos os direitos reservados.</p>
            <p>Feito com <span style="color: var(--amarelo);">💛</span> para os verdadeiros adeptos</p>
        </div>
    </footer>


  <script>
    const header = document.getElementById("header");
    let lastScrollY = window.scrollY;
    
    window.addEventListener("scroll", () => {
      const currentScrollY = window.scrollY;
      
      if (currentScrollY > 50) {
        header.classList.add("scrolled");
      } else {
        header.classList.remove("scrolled");
      }
      
      lastScrollY = currentScrollY;
    });

    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
          const headerHeight = document.getElementById('header').offsetHeight;
          const targetPosition = target.offsetTop - headerHeight;
          
          window.scrollTo({
            top: targetPosition,
            behavior: 'smooth'
          });
        }
      });
    });

    function showLoadingScreen() {
      const loadingScreen = document.createElement('div');
      loadingScreen.id = 'loading-screen';
      loadingScreen.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: linear-gradient(135deg, #0a0a0a 0%, #1a1a1a 100%);
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        z-index: 9999;
        color: white;
        transition: opacity 0.5s ease;
      `;
      
      loadingScreen.innerHTML = `
        <div style="text-align: center;">
          <div style="width: 100px; height: 100px; background: linear-gradient(135deg, #FFD700 0%, #FFA000 25%, #FFD700 50%, #FFED4E 75%, #FFD700 100%); background-size: 200% 200%; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 2.5rem; font-weight: 900; color: #0a0a0a; margin: 0 auto 2rem; animation: logoFloat 2s ease-in-out infinite, goldShimmer 4s ease-in-out infinite; box-shadow: 0 0 50px rgba(255, 215, 0, 0.4);">SC</div>
          <h2 style="font-size: 2rem; margin-bottom: 1rem; animation: titleGlow 2s ease-in-out infinite alternate; color: #FFD700;">Rio Tinto</h2>
          <div style="width: 200px; height: 4px; background: rgba(255, 255, 255, 0.1); border-radius: 2px; overflow: hidden; margin: 0 auto;">
            <div style="width: 0%; height: 100%; background: linear-gradient(135deg, #FFD700, #FFA000); border-radius: 2px; animation: loadingBar 3s ease-out forwards;"></div>
          </div>
          <p style="margin-top: 1rem; opacity: 0.7;">Carregando a magia do futebol...</p>
        </div>
      `;
      
      document.body.appendChild(loadingScreen);
      
      setTimeout(() => {
        loadingScreen.style.opacity = '0';
        setTimeout(() => {
          if (document.body.contains(loadingScreen)) {
            document.body.removeChild(loadingScreen);
          }
        }, 500);
      }, 3000);
    }

    document.addEventListener('DOMContentLoaded', () => {
      if (!sessionStorage.getItem('visited')) {
        showLoadingScreen();
        sessionStorage.setItem('visited', 'true');
      }
      
      console.log('🏆 SC Rio Tinto - Website carregado com sucesso!');
      console.log('💛 Força Rio Tinto! 💛');
    });
  </script>
</body>
</html>