<%--
    Document   : cartao-socio
    Created on : 14/12/2025, 17:26:40
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
    
    // Verificar se o utilizador é sócio
    boolean jaSocio = false;
    String numeroSocio = "";
    String dataSocio = "";
    String telefone = "";
    String cartaoCidadao = "";
    String dataNascimento = "";
    String quotaAnual = "";
    
    if (!estaLogado) {
        response.sendRedirect("Login.jsp");
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        // Configuração da base de dados
        String dbURL = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
        String dbUser = "root";
        String dbPass = "";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
        
        // Buscar dados do sócio
        String sql = "SELECT numero_socio, telemovel, cartao_de_cidadao, quota_anual, " +
                     "data_inscricao, data_nascimento " +
                     "FROM t_socio " +
                     "WHERE id_utilizador = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, idUtilizador);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            jaSocio = true;
            numeroSocio = rs.getString("numero_socio");
            telefone = rs.getString("telemovel");
            cartaoCidadao = rs.getString("cartao_de_cidadao");
            quotaAnual = rs.getString("quota_anual");
            
            // Formatar datas
            java.sql.Date dataInscricaoSQL = rs.getDate("data_inscricao");
            if (dataInscricaoSQL != null) {
                dataSocio = new java.text.SimpleDateFormat("dd/MM/yyyy").format(dataInscricaoSQL);
            } else {
                dataSocio = "Data não disponível";
            }
            
            java.sql.Date dataNascimentoSQL = rs.getDate("data_nascimento");
            if (dataNascimentoSQL != null) {
                dataNascimento = new java.text.SimpleDateFormat("dd/MM/yyyy").format(dataNascimentoSQL);
            }
        }
        
    } catch (Exception e) {
        out.println("<!-- Erro ao verificar sócio: " + e.getMessage() + " -->");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
    
    // Se não for sócio, redirecionar
    if (!jaSocio) {
        response.sendRedirect("Socios front page.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SC Rio Tinto - Cartão de Sócio</title>
  <link href="css/CssCartao-Socio.css" rel="stylesheet" type="text/css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>
<body>
  <!-- HEADER -->
  <header>
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
        
        <li class="user-dropdown">
          <button class="btn-header">
            <i class="fas fa-user-circle"></i>
            <%= primeiroNome %>
            <% if (isAdmin != null && isAdmin) { %>
              <span class="admin-badge">ADMIN</span>
            <% } %>
            <span class="socio-badge">✓ SÓCIO</span>
            <i class="fas fa-chevron-down" style="font-size: 0.7rem; margin-left: 0.3rem;"></i>
          </button>
          <div class="dropdown-menu">
            <div class="dropdown-header">
              <div class="user-name"><%= primeiroNome %> <%= ultimoNome %></div>
              <div class="user-email"><%= emailUtilizador %></div>
              <div style="margin-top: 0.5rem; color: #4CAF50; font-size: 0.8rem; font-weight: 600;">
                <i class="fas fa-star"></i> Sócio Ativo
              </div>
            </div>
            <a href="perfil.jsp" class="dropdown-item">
              <i class="fas fa-user"></i>
              Meu Perfil
            </a>
            <a href="pedidos.jsp" class="dropdown-item">
              <i class="fas fa-shopping-bag"></i>
              Meus Pedidos
            </a>
            <a href="MeusBilhetes.jsp" class="dropdown-item">
              <i class="fas fa-ticket"></i>
              Meus Bilhetes
            </a>
            <% if (isAdmin != null && isAdmin) { %>
            <div class="dropdown-divider"></div>
            <a href="admin.jsp" class="dropdown-item">
              <i class="fas fa-crown"></i>
              <span>Painel Admin</span>
            </a>
            <% } %>
            <div class="dropdown-divider"></div>
            <a href="logout.jsp" class="dropdown-item" style="color: rgba(255, 77, 77, 0.9);">
              <i class="fas fa-sign-out-alt" style="color: #ff4d4d;"></i>
              <span>Terminar Sessão</span>
            </a>
          </div>
        </li>
      </ul>
    </nav>
  </header>

  <div class="main-container">
    <!-- CABEÇALHO DA PÁGINA -->
    <div class="page-header">
      <h1 class="page-title">Cartão de <span class="highlight">Sócio</span></h1>
      <p class="page-subtitle">O teu cartão digital oficial do SC Rio Tinto 💛🖤</p>
    </div>

    <!-- CARTÃO DE SÓCIO -->
    <div class="card-container">
      <div class="socio-card" id="socioCard">
        <!-- FRENTE DO CARTÃO -->
        <div class="card-face card-front">
          <div class="card-content">
            <!-- ÁREA DA FOTO -->
            <div class="card-photo-section">
              <div class="card-photo">
                <i class="fas fa-user"></i>
              </div>
            </div>

            <!-- ÁREA DE INFORMAÇÕES -->
            <div class="card-info-section">
              <div class="card-header-top">
                <div class="card-title">
                  Não há gente<br>como a gente!
                </div>
                <div class="card-logo-badge">
                  <img src="images/Logo SCRT.jpg" alt="SC Rio Tinto" onerror="this.parentElement.innerHTML='<div style=\'font-size:2rem;color:#B8860B;font-weight:900;\'>SC<br>RT</div>'">
                </div>
              </div>

              <div class="card-main-info">
                <div class="card-name">
                  <%= primeiroNome != null ? primeiroNome.toUpperCase() : "" %><br>
                  <%= ultimoNome != null ? ultimoNome.toUpperCase() : "" %>
                </div>

                <div class="card-details-grid">
                  <div class="card-detail">
                    <div class="card-detail-label">Sócio desde</div>
                    <div class="card-detail-value"><%= dataSocio %></div>
                  </div>
                  <div class="card-detail">
                    <div class="card-detail-label">Nr. de Sócio</div>
                    <div class="card-detail-value">#<%= numeroSocio %></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- VERSO DO CARTÃO -->
        <div class="card-face card-back">
          <div class="card-content">
            <div class="qr-section">
              <div class="qr-code">
                <img src="https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=SOCIO-<%= numeroSocio %>-<%= idUtilizador %>" alt="QR Code" crossorigin="anonymous">
              </div>
              <div class="qr-text">
                <strong>Apresente este QR Code</strong><br>
                para validar o seu cartão de sócio<br>
                nos jogos e eventos do clube
              </div>
            </div>

            <div class="card-back-footer">
              <p>SC Rio Tinto</p>
              <p>www.scriotinto.pt | geral@scriotinto.pt</p>
              <p>Desde 1949 💛🖤</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- BOTÕES DE AÇÃO -->
    <div class="actions-container">
      <button type="button" class="btn-action btn-primary" onclick="flipCard()">
        <i class="fas fa-sync-alt"></i>
        Virar Cartão
      </button>

      <button type="button" class="btn-action btn-secondary" onclick="downloadCard()">
        <i class="fas fa-download"></i>
        Guardar como Imagem
      </button>
    </div>

    <!-- INFORMAÇÕES ADICIONAIS -->
    <div class="info-section">
      <h2 class="info-title">📋 Informações do Sócio</h2>
      <div class="info-grid">
        <div class="info-item">
          <div class="info-item-icon"><i class="fas fa-user"></i></div>
          <div class="info-item-label">Nome Completo</div>
          <div class="info-item-value"><%= primeiroNome %> <%= ultimoNome %></div>
        </div>
        <div class="info-item">
          <div class="info-item-icon"><i class="fas fa-envelope"></i></div>
          <div class="info-item-label">Email</div>
          <div class="info-item-value"><%= emailUtilizador %></div>
        </div>
        <% if (telefone != null && !telefone.isEmpty()) { %>
        <div class="info-item">
          <div class="info-item-icon"><i class="fas fa-phone"></i></div>
          <div class="info-item-label">Telemóvel</div>
          <div class="info-item-value"><%= telefone %></div>
        </div>
        <% } %>
        <% if (dataNascimento != null && !dataNascimento.isEmpty()) { %>
        <div class="info-item">
          <div class="info-item-icon"><i class="fas fa-birthday-cake"></i></div>
          <div class="info-item-label">Data de Nascimento</div>
          <div class="info-item-value"><%= dataNascimento %></div>
        </div>
        <% } %>
        <% if (cartaoCidadao != null && !cartaoCidadao.isEmpty()) { %>
        <div class="info-item">
          <div class="info-item-icon"><i class="fas fa-id-card"></i></div>
          <div class="info-item-label">Cartão de Cidadão</div>
          <div class="info-item-value"><%= cartaoCidadao %></div>
        </div>
        <% } %>
        <% if (quotaAnual != null && !quotaAnual.isEmpty()) { %>
        <div class="info-item">
          <div class="info-item-icon"><i class="fas fa-euro-sign"></i></div>
          <div class="info-item-label">Quota Anual</div>
          <div class="info-item-value"><%= quotaAnual %>€</div>
        </div>
        <% } %>
      </div>
    </div>
  </div>

  <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
  <script>
    let isFlipping = false;
    
    // Função para virar o cartão
    function flipCard() {
      if (isFlipping) return;
      isFlipping = true;
      
      const card = document.getElementById('socioCard');
      card.classList.toggle('flipped');
      
      setTimeout(() => {
        isFlipping = false;
      }, 800);
    }

    // Função melhorada para download do cartão
    async function downloadCard() {
      // Criar overlay de loading
      const overlay = document.createElement('div');
      overlay.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.95);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
        backdrop-filter: blur(10px);
      `;
      
      const loadingBox = document.createElement('div');
      loadingBox.style.cssText = `
        background: linear-gradient(135deg, #1a1a1a, #2a2a2a);
        padding: 3rem 4rem;
        border-radius: 20px;
        text-align: center;
        border: 3px solid #FFD700;
        box-shadow: 0 20px 60px rgba(255, 215, 0, 0.3);
      `;
      
      loadingBox.innerHTML = `
        <div style="font-size: 3rem; margin-bottom: 1rem; animation: spin 1s linear infinite;">⚙️</div>
        <div style="color: #FFD700; font-size: 1.5rem; font-weight: 700; margin-bottom: 0.5rem;">
          A processar o cartão...
        </div>
        <div style="color: rgba(255, 255, 255, 0.7); font-size: 1rem;">
          Aguarde um momento
        </div>
        <style>
          @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
          }
        </style>
      `;
      
      overlay.appendChild(loadingBox);
      document.body.appendChild(overlay);
      
      try {
        const card = document.getElementById('socioCard');
        const isFlipped = card.classList.contains('flipped');
        
        // Garantir que está na frente
        if (isFlipped) {
          card.classList.remove('flipped');
          await new Promise(resolve => setTimeout(resolve, 850));
        }
        
        // Capturar FRENTE
        loadingBox.querySelector('div:nth-child(2)').textContent = 'Capturando frente...';
        const frontFace = card.querySelector('.card-front');
        const frontCanvas = await html2canvas(frontFace, {
          scale: 3,
          useCORS: true,
          allowTaint: true,
          backgroundColor: null,
          logging: false,
          width: 850,
          height: 540
        });
        
        // Capturar VERSO - criar clone sem rotação
        loadingBox.querySelector('div:nth-child(2)').textContent = 'Capturando verso...';
        const backFace = card.querySelector('.card-back');
        
        // Criar clone do verso sem a transformação
        const backClone = backFace.cloneNode(true);
        backClone.style.position = 'fixed';
        backClone.style.top = '-9999px';
        backClone.style.left = '-9999px';
        backClone.style.transform = 'none';
        backClone.style.width = '850px';
        backClone.style.height = '540px';
        backClone.style.backfaceVisibility = 'visible';
        document.body.appendChild(backClone);
        
        // Pré-carregar a imagem do QR Code no clone
        const qrImg = backClone.querySelector('.qr-code img');
        if (qrImg) {
          await new Promise((resolve) => {
            if (qrImg.complete) {
              resolve();
            } else {
              qrImg.onload = resolve;
              qrImg.onerror = resolve;
            }
          });
        }
        
        // Aguardar renderização
        await new Promise(resolve => setTimeout(resolve, 500));
        
        const backCanvas = await html2canvas(backClone, {
          scale: 3,
          useCORS: true,
          allowTaint: true,
          backgroundColor: '#1a1a1a',
          logging: false,
          width: 850,
          height: 540
        });
        
        // Remover clone
        document.body.removeChild(backClone);
        
        // Restaurar estado original do cartão
        if (!isFlipped) {
          card.classList.remove('flipped');
        } else {
          card.classList.add('flipped');
        }
        
        // Combinar as duas imagens
        loadingBox.querySelector('div:nth-child(2)').textContent = 'Finalizando...';
        const combinedCanvas = document.createElement('canvas');
        const ctx = combinedCanvas.getContext('2d');
        
        const padding = 80;
        const cardWidth = 850 * 3;
        const cardHeight = 540 * 3;
        
        combinedCanvas.width = cardWidth;
        combinedCanvas.height = (cardHeight * 2) + (padding * 3);
        
        // Fundo preto
        ctx.fillStyle = '#0a0a0a';
        ctx.fillRect(0, 0, combinedCanvas.width, combinedCanvas.height);
        
        // Desenhar FRENTE
        ctx.drawImage(frontCanvas, 0, padding, cardWidth, cardHeight);
        
        // Texto entre os cartões
        ctx.fillStyle = '#FFD700';
        ctx.font = 'bold 48px Poppins, sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText('FRENTE', combinedCanvas.width / 2, padding + cardHeight + 60);
        
        // Desenhar VERSO
        ctx.drawImage(backCanvas, 0, padding * 2 + cardHeight, cardWidth, cardHeight);
        
        ctx.fillText('VERSO', combinedCanvas.width / 2, padding * 2 + cardHeight + 60);
        
        // Download
        const link = document.createElement('a');
        link.download = 'cartao-socio-<%= numeroSocio %>.png';
        link.href = combinedCanvas.toDataURL('image/png', 1.0);
        link.click();
        
        // Remover loading
        document.body.removeChild(overlay);
        
        // Mensagem de sucesso
        const successMsg = document.createElement('div');
        successMsg.style.cssText = `
          position: fixed;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          background: linear-gradient(135deg, #10B981, #059669);
          color: white;
          padding: 2rem 3rem;
          border-radius: 15px;
          font-size: 1.2rem;
          font-weight: 700;
          z-index: 9999;
          box-shadow: 0 20px 60px rgba(16, 185, 129, 0.4);
          animation: slideIn 0.5s ease;
        `;
        successMsg.innerHTML = `
          <div style="font-size: 3rem; margin-bottom: 0.5rem; text-align: center;">✅</div>
          <div>Cartão guardado com sucesso!</div>
          <div style="font-size: 0.9rem; margin-top: 0.5rem; opacity: 0.9;">
            Ambos os lados foram salvos numa única imagem
          </div>
          <style>
            @keyframes slideIn {
              from { 
                transform: translate(-50%, -50%) scale(0.8);
                opacity: 0;
              }
              to { 
                transform: translate(-50%, -50%) scale(1);
                opacity: 1;
              }
            }
          </style>
        `;
        document.body.appendChild(successMsg);
        
        setTimeout(() => {
          successMsg.style.animation = 'slideIn 0.5s ease reverse';
          setTimeout(() => {
            if (document.body.contains(successMsg)) {
              document.body.removeChild(successMsg);
            }
          }, 500);
        }, 3000);
        
      } catch (error) {
        console.error('Erro ao gerar imagem:', error);
        document.body.removeChild(overlay);
        
        const errorMsg = document.createElement('div');
        errorMsg.style.cssText = `
          position: fixed;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          background: linear-gradient(135deg, #EF4444, #DC2626);
          color: white;
          padding: 2rem 3rem;
          border-radius: 15px;
          font-size: 1.2rem;
          font-weight: 700;
          z-index: 9999;
          box-shadow: 0 20px 60px rgba(239, 68, 68, 0.4);
        `;
        errorMsg.innerHTML = `
          <div style="font-size: 3rem; margin-bottom: 0.5rem; text-align: center;">❌</div>
          <div>Erro ao guardar o cartão</div>
          <div style="font-size: 0.85rem; margin-top: 0.5rem; opacity: 0.9;">
            Por favor, tente novamente
          </div>
        `;
        document.body.appendChild(errorMsg);
        
        setTimeout(() => {
          if (document.body.contains(errorMsg)) {
            document.body.removeChild(errorMsg);
          }
        }, 3000);
      }
    }

    // Event listener para teclas
    document.addEventListener('keydown', (e) => {
      if ((e.key === ' ' || e.key === 'Enter') && !isFlipping) {
        e.preventDefault();
        flipCard();
      }
    });
    
    // Click no cartão para virar
    const socioCard = document.getElementById('socioCard');
    socioCard.addEventListener('click', flipCard);

    console.log('💛🖤 Cartão de Sócio SC Rio Tinto - Carregado e funcional!');
  </script>
</body>
</html>