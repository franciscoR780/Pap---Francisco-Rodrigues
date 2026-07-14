<%--
    Document   : Sobre
    Created on : 02/12/2025, 11:41:09
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%
    // Verificar sessão
    Integer idUtilizador = (Integer) session.getAttribute("id_utilizador");
    String primeiroNome = (String) session.getAttribute("primeiro_nome");
    String ultimoNome = (String) session.getAttribute("ultimo_nome");
    String emailUtilizador = (String) session.getAttribute("email");
    Boolean isAdmin = (Boolean) session.getAttribute("is_admin");
    
    if (isAdmin == null) isAdmin = false;
    boolean estaLogado = (idUtilizador != null);
    
    // Verificar se é sócio
    boolean jaSocio = false;
    String numeroSocio = null;
    
    if (estaLogado) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection connSocio = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
            PreparedStatement pstmt = connSocio.prepareStatement(
                "SELECT numero_socio FROM t_socio WHERE id_utilizador = ?");
            pstmt.setInt(1, idUtilizador);
            ResultSet rsSocio = pstmt.executeQuery();
            
            if (rsSocio.next()) {
                jaSocio = true;
                numeroSocio = rsSocio.getString("numero_socio");
            }
            
            rsSocio.close();
            pstmt.close();
            connSocio.close();
        } catch (Exception e) {
            out.println("<!-- Erro ao verificar sócio: " + e.getMessage() + " -->");
        }
    }
%>

<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SC Rio Tinto - Sobre Nós</title>
  <link href="css/CssSobre.css" rel="stylesheet" type="text/css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>
<body>
  <!-- FLOATING PARTICLES -->
  <div class="particles">
    <div class="particle" style="left: 5%; animation-delay: 0s;"></div>
    <div class="particle" style="left: 15%; animation-delay: 1.2s;"></div>
    <div class="particle" style="left: 25%; animation-delay: 2.4s;"></div>
    <div class="particle" style="left: 35%; animation-delay: 3.6s;"></div>
    <div class="particle" style="left: 45%; animation-delay: 4.8s;"></div>
    <div class="particle" style="left: 55%; animation-delay: 3s;"></div>
    <div class="particle" style="left: 65%; animation-delay: 1.8s;"></div>
    <div class="particle" style="left: 75%; animation-delay: 4.2s;"></div>
    <div class="particle" style="left: 85%; animation-delay: 0.6s;"></div>
    <div class="particle" style="left: 95%; animation-delay: 2.6s;"></div>
  </div>

  <!-- LASER GRID -->
  <div class="laser-grid"></div>

  <!-- HEADER -->
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

  <!-- HERO SECTION -->
  <section class="hero">
    <div class="hero-content">
      <div class="hero-badge">DESDE 1923</div>
      <h1>
        <% if (estaLogado) { %>
          Bem-vindo, <span class="highlight"><%= primeiroNome %></span>!
        <% } else { %>
          Sobre o <span class="highlight">Rio Tinto</span>
        <% } %>
      </h1>
      <p>Mais de 100 anos de história, tradição e paixão no coração de Gondomar. Descobre a nossa jornada épica!</p>
      
      <div class="hero-stats">
        <div class="hero-stat">
          <div class="hero-stat-number">100+</div>
          <div class="hero-stat-label">Anos</div>
        </div>
        <div class="hero-stat">
          <div class="hero-stat-number">1923</div>
          <div class="hero-stat-label">Fundação</div>
        </div>
      </div>
    </div>
  </section>

  <!-- HISTÓRIA SECTION -->
  <section class="content-section" id="historia">
    <div class="container">
      <div class="section-title fade-in">
        <h2>A Nossa <span class="gold-text">História</span></h2>
        <p>Uma jornada centenária de paixão, luta e glória que começou em 1923 e continua a escrever-se todos os dias.</p>
      </div>

      <div class="timeline fade-in">
        <div class="timeline-item">
          <div class="timeline-content">
            <div class="timeline-year">1923</div>
            <div class="timeline-title">A Fundação Gloriosa</div>
            <div class="timeline-text">Em 1 de Julho de 1923, um grupo visionário de Riotintenses, incluindo Serafim Pinto Morgado, João de Sousa Nogueira, Custódio Campos Moura, António Lopes Júnior e António José de Almeida (Finguilo), uniram forças para criar algo extraordinário - o Sport Clube Rio Tinto nascia para eternidade!</div>
          </div>
        </div>

        <div class="timeline-item">
          <div class="timeline-content">
            <div class="timeline-year">1930s</div>
            <div class="timeline-title">Os Primeiros Passos</div>
            <div class="timeline-text">A década de 30 marcou os primeiros grandes momentos do clube, estabelecendo as bases sólidas que sustentariam gerações de triunfos. As cores amarelo e preto começavam a ganhar respeito e admiração em toda a região do Grande Porto.</div>
          </div>
        </div>

        <div class="timeline-item">
          <div class="timeline-content">
            <div class="timeline-year">1950s</div>
            <div class="timeline-title">Era de Crescimento</div>
            <div class="timeline-text">Os anos 50 trouxeram uma nova dinâmica ao clube, com investimentos na formação e infraestruturas que posicionaram o Rio Tinto como uma referência no futebol distrital, cultivando talentos que levariam o nome do clube muito além das fronteiras de Gondomar.</div>
          </div>
        </div>

        <div class="timeline-item">
          <div class="timeline-content">
            <div class="timeline-year">1980s</div>
            <div class="timeline-title">Modernização</div>
            <div class="timeline-text">A década de 80 representou um marco na modernização do clube, com a implementação de novas metodologias de treino, melhoria das condições de jogo e uma visão mais profissional que elevou significativamente o nível competitivo da equipa.</div>
          </div>
        </div>

        <div class="timeline-item">
          <div class="timeline-content">
            <div class="timeline-year">2000s</div>
            <div class="timeline-title">Novo Milénio, Novos Sonhos</div>
            <div class="timeline-text">O século XXI trouxe renovadas ambições e projetos inovadores. O clube expandiu as suas atividades, criou equipas femininas e de formação, estabelecendo-se como um pilar fundamental na comunidade riotintense.</div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- STATS SECTION -->
  <section class="content-section" style="background: linear-gradient(135deg, rgba(10, 10, 10, 0.92) 0%, rgba(26, 26, 26, 0.92) 100%); position: relative;">
    <div style="content: ''; position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: url('https://images.unsplash.com/photo-1508098682722-e99c43a406b2?ixlib=rb-4.0.3&auto=format&fit=crop&w=2000&q=80') center/cover no-repeat; opacity: 0.12; z-index: -1;"></div>
    <div class="container">
      <div class="section-title fade-in">
        <h2>Os Nossos <span class="gold-text">Números</span></h2>
        <p>Estatísticas que contam a história do nosso sucesso e dedicação ao longo de mais de um século.</p>
      </div>
      
      <div class="stats-grid fade-in">
        <div class="stat-card">
          <div class="stat-number">15+</div>
          <div class="stat-label">Títulos</div>
        </div>
        <div class="stat-card">
          <div class="stat-number">500+</div>
          <div class="stat-label">Jogadores Formados</div>
        </div>
        <div class="stat-card">
          <div class="stat-number">2000+</div>
          <div class="stat-label">Sócios</div>
        </div>
      </div>
    </div>
  </section>
  
  <!-- CULTURA SECTION -->
  <section class="content-section" id="cultura">
    <div class="container">
      <div class="section-title fade-in">
        <h2>A Nossa <span class="gold-text">Cultura</span></h2>
        <p>Valores, tradições e princípios que nos definem como muito mais do que um simples clube de futebol.</p>
      </div>

      <div class="cultura-content fade-in">
        <div class="cultura-card">
          
          <h3 style="color: var(--amarelo); font-size: 2rem; margin-bottom: 2rem;">Mais do que Futebol</h3>
          <p style="margin-bottom: 1.5rem;">
            O Sport Clube Rio Tinto transcende o desporto. Somos uma <span class="cultura-highlight">família unida</span> por laços que vão muito além do campo de jogo. Aqui, cada vitória é celebrada em conjunto, cada derrota é partilhada com solidariedade, e cada momento é vivido com a intensidade que só o amor verdadeiro pelo clube pode proporcionar.
          </p>
          <p style="margin-bottom: 1.5rem;">
            As nossas <span class="cultura-highlight">cores amarelo e preto</span> não são apenas uma combinação cromática - são símbolos de força, determinação e elegância que representam o espírito indomável dos riotintenses. Quando vestimos estas cores, carregamos connosco o peso glorioso de mais de um século de história e tradição.
          </p>
        </div>
        
        <div class="cultura-card">
          
          <h3 style="color: var(--amarelo); font-size: 2
	rem; margin-bottom: 2rem;">Os Nossos Valores</h3>
          <div class="valores-list">
            <div class="valor-item">
              <div class="valor-bullet"></div>
              <div class="valor-text">Paixão Inabalável</div>
            </div>
            <div class="valor-item">
              <div class="valor-bullet"></div>
              <div class="valor-text">Respeito e Fair Play</div>
            </div>
            <div class="valor-item">
              <div class="valor-bullet"></div>
              <div class="valor-text">Espírito de Comunidade</div>
            </div>
            <div class="valor-item">
              <div class="valor-bullet"></div>
              <div class="valor-text">Formação e Desenvolvimento</div>
            </div>
            <div class="valor-item">
              <div class="valor-bullet"></div>
              <div class="valor-text">Tradição e Inovação</div>
            </div>
            <div class="valor-item">
              <div class="valor-bullet"></div>
              <div class="valor-text">Compromisso com a Excelência</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- CONQUISTAS SECTION -->
  <section class="content-section" id="conquistas">
    <div class="container">
      <div class="section-title fade-in">
        <h2>As Nossas <span class="gold-text">Conquistas</span></h2>
        <p>Momentos de glória que marcaram a história centenária do clube e ficaram eternizados na memória dos riotintenses.</p>
      </div>

      <div class="conquistas-grid fade-in">
        <div class="conquista-card">
          
          <div class="conquista-title">Campeonatos Distritais</div>
          <div class="conquista-year">15x</div>
        </div>

        <div class="conquista-card">
          
          <div class="conquista-title">Taças Regionais</div>
          <div class="conquista-year">21x</div>
        </div>

        <div class="conquista-card">
          
          <div class="conquista-title">Subidas de Divisão</div>
          <div class="conquista-year">15x</div>
        </div>
      </div>
    </div>
  </section>

  <!-- ESTÁDIO SECTION -->
  <section class="content-section" id="estadio">
    <div class="container">
      <div class="section-title fade-in">
        <h2>O Nosso <span class="gold-text">Estádio</span></h2>
        <p>A casa onde os sonhos ganham vida e a paixão riotintense explode em cada jogo.</p>
      </div>

      <div class="estadio-info fade-in">
        <p style="font-size: 1.2rem; line-height: 1.8; margin-bottom: 2rem;">
          O <span class="cultura-highlight">Estádio do Rio Tinto</span> é muito mais do que um simples campo de jogo - é o coração pulsante do clube, o santuário onde gerações de adeptos se reúnem para apoiar incondicionalmente a sua equipa. Com uma atmosfera única e vibrante, é aqui que a magia acontece, onde cada grito de incentivo ecoa como um trovão e cada golo é celebrado com uma explosão de emoção genuína.
        </p>

        <div class="estadio-details">
          <div class="detail-item">
            <div class="detail-label">Capacidade</div>
            <div class="detail-value">1.000</div>
          </div>
          <div class="detail-item">
            <div class="detail-label">Inauguração</div>
            <div class="detail-value">2011</div>
          </div>
          <div class="detail-item">
            <div class="detail-label">Relva</div>
            <div class="detail-value">Natural</div>
          </div>         
        </div>

        <h3 style="color: var(--amarelo); font-size: 2rem; margin-top: 3rem; margin-bottom: 2rem; text-align: center;">Melhoramentos Recentes</h3>
        
        <div class="melhoramentos-grid">
          <div class="melhoria-card">
            <div class="melhoria-icon">💡</div>
            <h4 style="color: var(--branco); margin-bottom: 1rem;">Sistema de Iluminação</h4>
            <p style="opacity: 0.8;">Novo sistema LED de última geração para jogos noturnos</p>
          </div>

          <div class="melhoria-card">
            <div class="melhoria-icon">🪑</div>
            <h4 style="color: var(--branco); margin-bottom: 1rem;">Bancadas Renovadas</h4>
            <p style="opacity: 0.8;">Assentos modernos e confortáveis para os adeptos</p>
          </div>

          <div class="melhoria-card">
            <div class="melhoria-icon">🏋️</div>
            <h4 style="color: var(--branco); margin-bottom: 1rem;">Balneários Modernizados</h4>
            <p style="opacity: 0.8;">Instalações de treino e recuperação de elite</p>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- CTA SECTION -->
  <section class="cta-section fade-in">
    <div class="container" style="position: relative; z-index: 10;">
      <h2 style="font-size: 3.5rem; font-weight: 900; margin-bottom: 1.5rem; text-transform: uppercase;">
        Junta-te à <span class="gold-text">Nossa Família</span>
      </h2>
      <p style="font-size: 1.3rem; max-width: 700px; margin: 0 auto 3rem auto; opacity: 0.9;">
        Faz parte da história centenária do Sport Clube Rio Tinto. Torna-te sócio e vive cada momento com paixão!
      </p>
      <% if (!jaSocio) { %>
        <a href="Socios front page.jsp" class="btn-hero">
          <i class="fas fa-heart"></i>
          Tornar-me Sócio
          <i class="fas fa-arrow-right"></i>
        </a>
      <% } else { %>
        <a href="cartao-socio.jsp" class="btn-hero">
          <i class="fas fa-id-card"></i>
          Ver Cartão de Sócio
          <i class="fas fa-arrow-right"></i>
        </a>
      <% } %>
    </div>
  </section>

  <!-- FOOTER -->
  <footer>
    <div class="social-links">
      <a href="https://www.instagram.com/sportcluberiotinto/" title="Instagram"><i class="fab fa-instagram"></i></a>
    </div>
    <p style="font-size: 0.95rem; opacity: 0.8; margin-bottom: 0.5rem;">
      &copy; 2025 Sport Clube Rio Tinto. Todos os direitos reservados.
    </p>
    <p style="font-size: 0.85rem; opacity: 0.6;">
      Desde 1923 | Gondomar, Portugal
    </p>
  </footer>

  <script>
    // HEADER SCROLL EFFECT
    const header = document.getElementById('header');
    let lastScroll = 0;

    window.addEventListener('scroll', () => {
      const currentScroll = window.pageYOffset;
      
      if (currentScroll > 100) {
        header.classList.add('scrolled');
      } else {
        header.classList.remove('scrolled');
      }
      
      lastScroll = currentScroll;
    });

    // FADE IN ANIMATION ON SCROLL
    const observerOptions = {
      threshold: 0.1,
      rootMargin: '0px 0px -100px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
        }
      });
    }, observerOptions);

    document.querySelectorAll('.fade-in').forEach(el => observer.observe(el));

    // SMOOTH SCROLL
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
          target.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
          });
        }
      });
    });

    // PARTICLES RANDOMIZATION
    const particles = document.querySelectorAll('.particle');
    particles.forEach(particle => {
      const randomSize = Math.random() * 4 + 2;
      const randomDuration = Math.random() * 5 + 8;
      const randomDelay = Math.random() * 5;
      
      particle.style.width = randomSize + 'px';
      particle.style.height = randomSize + 'px';
      particle.style.animationDuration = randomDuration + 's';
      particle.style.animationDelay = randomDelay + 's';
    });

    // TIMELINE ITEMS STAGGERED ANIMATION
    const timelineItems = document.querySelectorAll('.timeline-item');
    timelineItems.forEach((item, index) => {
      item.style.animationDelay = `${index * 0.2}s`;
    });

    // STATS COUNTER ANIMATION
    const statNumbers = document.querySelectorAll('.stat-number, .hero-stat-number');
    
    const animateCounter = (element) => {
      const target = element.textContent;
      
      // Verificar se é um número válido
      if (target === '∞' || isNaN(parseInt(target))) {
        return;
      }
      
      const targetNum = parseInt(target.replace(/\D/g, ''));
      const duration = 2000;
      const increment = targetNum / (duration / 16);
      let current = 0;
      
      const updateCounter = () => {
        current += increment;
        if (current < targetNum) {
          element.textContent = Math.floor(current) + '+';
          requestAnimationFrame(updateCounter);
        } else {
          element.textContent = target;
        }
      };
      
      updateCounter();
    };

    const statsObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          animateCounter(entry.target);
          statsObserver.unobserve(entry.target);
        }
      });
    }, { threshold: 0.5 });

    statNumbers.forEach(stat => {
      if (stat.textContent !== '∞') {
        statsObserver.observe(stat);
      }
    });
  </script>
</body>
</html>