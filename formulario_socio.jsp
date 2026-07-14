<%--
    Document   : formulario_socio
    Created on : 22/12/2025, 21:39:44
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!-- FONTES -->
<link href="css/CssFormulario_Socio.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">

<%
    // BUSCAR DADOS DO UTILIZADOR PARA AUTO-PREENCHER
    String telefoneUtilizador = "";
    String dataNascimentoUtilizador = "";
    
    Integer idUtilizadorLogado = (Integer) session.getAttribute("id_utilizador");
    
    if (idUtilizadorLogado != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection connDados = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
            
            String sqlDados = "SELECT telefone, data_nascimento FROM t_utilizadores WHERE id_utilizador = ?";
            PreparedStatement stmtDados = connDados.prepareStatement(sqlDados);
            stmtDados.setInt(1, idUtilizadorLogado);
            
            ResultSet rsDados = stmtDados.executeQuery();
            
            if (rsDados.next()) {
                telefoneUtilizador = rsDados.getString("telefone") != null ? rsDados.getString("telefone") : "";
                dataNascimentoUtilizador = rsDados.getString("data_nascimento") != null ? rsDados.getString("data_nascimento") : "";
            }
            
            rsDados.close();
            stmtDados.close();
            connDados.close();
        } catch (Exception e) {
            // Em caso de erro, os campos ficam vazios
        }
    }
    
    // PROCESSAMENTO DO BACKEND
    String mensagem = "";
    String tipoMensagem = "";
    
    if (request.getMethod().equals("POST")) {
        String acao = request.getParameter("acao");
        String url = "jdbc:mysql://localhost:3306/pap";
        String username = "root";
        String password = "";
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, username, password);
            
            if ("inserir".equals(acao)) {
                String numero = request.getParameter("numero_socio");
                String telemovel = request.getParameter("phone");
                String cartao_cidadao = request.getParameter("cartao_cidadao");
                String id_utilizador = request.getParameter("id_utilizador");
                String data_nascimento = request.getParameter("birthDate");

                // INSERIR NA TABELA t_socio
                String sql = "INSERT INTO t_socio (numero_socio, telemovel, cartao_de_cidadao, id_utilizador, data_nascimento) VALUES (?, ?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql);
                statement.setString(1, numero);
                statement.setString(2, telemovel);
                statement.setString(3, cartao_cidadao);
                statement.setString(4, id_utilizador);
                statement.setString(5, data_nascimento);

                int rowsInserted = statement.executeUpdate();
                
                if (rowsInserted > 0) {
                    // ✅ ATUALIZAR O TIPO_UTILIZADOR PARA 'SOCIO'
                    String sqlUpdate = "UPDATE t_utilizadores SET tipo_utilizador = 'socio' WHERE id_utilizador = ?";
                    PreparedStatement stmtUpdate = conn.prepareStatement(sqlUpdate);
                    stmtUpdate.setString(1, id_utilizador);
                    stmtUpdate.executeUpdate();
                    stmtUpdate.close();
                    
                    // ✅ ATUALIZAR A SESSÃO SE FOR O UTILIZADOR LOGADO
                    Integer idLogado = (Integer) session.getAttribute("id_utilizador");
                    if (idLogado != null && idLogado == Integer.parseInt(id_utilizador)) {
                        session.setAttribute("tipo_utilizador", "socio");
                    }
                    
                    mensagem = "Inscrição realizada com sucesso! Bem-vindo à família SC Rio Tinto! 🎉";
                    tipoMensagem = "success";
                } else {
                    mensagem = "Erro na inserção. Por favor, tenta novamente.";
                    tipoMensagem = "error";
                }
                statement.close();
            }
            
            conn.close();
        } catch (Exception e) {
            mensagem = "Ocorreu um erro: " + e.getMessage();
            tipoMensagem = "error";
        }
    }
%>

<!-- MODAL OVERLAY (FUNDO PRETO) -->
<div id="modalSocio" class="modal-overlay" <%= !mensagem.isEmpty() ? "style='display:flex;'" : "" %>>
  <div class="modal-content">
    <!-- BOTÃO FECHAR -->
    <button onclick="window.location.href='Socios front page.jsp'" class="btn-close">
    <i class="fas fa-times"></i>

    </button>
    
    <!-- MENSAGEM DE SUCESSO/ERRO -->
    <% if (!mensagem.isEmpty()) { %>
      <div class="message-box <%= tipoMensagem %>">
        <i class="fas fa-<%= tipoMensagem.equals("success") ? "check-circle" : "exclamation-circle" %>"></i>
        <%= mensagem %>
        <% if (tipoMensagem.equals("success")) { %>
          <div style="margin-top: 1rem; font-size: 0.9rem;">
            ✨ O teu perfil foi atualizado para <strong>SÓCIO</strong>!
          </div>
        <% } %>
      </div>
    <% } %>
    
    <!-- FORMULÁRIO -->
    <h2>Inscreve-te Já!</h2>
    <p class="subtitle">Preenche o formulário e junta-te à família Rio Tinto</p>
    
    <form method="post">
      <input type="hidden" name="acao" value="inserir">
      
      <div class="form-row">
        <div class="form-group">
          <label for="id_utilizador">
            <i class="fas fa-user"></i> UTILIZADOR *
          </label>
          <select name="id_utilizador" id="id_utilizador" required onchange="carregarDadosUtilizador(this.value)">
<%
    Boolean isAdmin = (Boolean) session.getAttribute("is_admin");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection connUtil = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
        
        String query;
        PreparedStatement stmtUtil;
        
        if (isAdmin != null && isAdmin) {
            // ADMIN vê todos os utilizadores
            query = "SELECT id_utilizador, primeiro_nome, ultimo_nome FROM t_utilizadores ORDER BY primeiro_nome";
            stmtUtil = connUtil.prepareStatement(query);
        } else {
            // UTILIZADOR NORMAL só vê ele próprio
            query = "SELECT id_utilizador, primeiro_nome, ultimo_nome FROM t_utilizadores WHERE id_utilizador = ?";
            stmtUtil = connUtil.prepareStatement(query);
            stmtUtil.setInt(1, idUtilizadorLogado != null ? idUtilizadorLogado : 0);
        }
        
        ResultSet rsUtil = stmtUtil.executeQuery();
        
        if (isAdmin != null && isAdmin) {
            out.println("<option value=''>Selecione um utilizador...</option>");
        }
        
        while (rsUtil.next()) {
            int idUtil = rsUtil.getInt("id_utilizador");
            String nomeCompleto = rsUtil.getString("primeiro_nome") + " " + rsUtil.getString("ultimo_nome");
            String selected = (idUtilizadorLogado != null && idUtil == idUtilizadorLogado) ? "selected" : "";
%>
            <option value="<%= idUtil %>" <%= selected %>><%= nomeCompleto %></option>
<%
        }
        rsUtil.close();
        stmtUtil.close();
        connUtil.close();
    } catch (Exception e) {
        out.println("<option value=''>Erro ao carregar utilizadores</option>");
    }
%>
          </select>
        </div>
        
        <div class="form-group">
          <label for="numero_socio">
            <i class="fas fa-id-card"></i> NÚMERO DE SÓCIO *
          </label>
          <input type="text" name="numero_socio" id="numero_socio" placeholder="Ex: 2025001" required>
        </div>
      </div>
      
      <div class="form-row">
        <div class="form-group">
          <label for="phone">
            <i class="fas fa-phone"></i> TELEMÓVEL *
          </label>
          <input type="tel" name="phone" id="phone" placeholder="9xxxxxxxx" pattern="[0-9]{9}" value="<%= telefoneUtilizador %>" required>
        </div>
        
        <div class="form-group">
          <label for="cartao_cidadao">
            <i class="fas fa-address-card"></i> CARTÃO DE CIDADÃO *
          </label>
          <input type="text" name="cartao_cidadao" id="cartao_cidadao" placeholder="00000000 0 ZZ0" required>
        </div>
      </div>
      
      <div class="form-group full-width">
        <label for="birthDate">
          <i class="fas fa-calendar"></i> DATA DE NASCIMENTO *
        </label>
        <input type="date" name="birthDate" id="birthDate" value="<%= dataNascimentoUtilizador %>" required>
      </div>
      
      <button type="submit" class="btn-submit">
        <i class="fas fa-user-plus"></i> TORNAR-ME SÓCIO
      </button>
    </form>
  </div>
</div>
<script>
  // DADOS DOS UTILIZADORES (para ADMIN)
  const utilizadoresDados = {};
  
<%
    // Criar objeto JavaScript com dados de todos os utilizadores (para ADMIN)
    if (isAdmin != null && isAdmin) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection connJS = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
            
            String queryJS = "SELECT id_utilizador, telefone, data_nascimento FROM t_utilizadores";
            PreparedStatement stmtJS = connJS.prepareStatement(queryJS);
            ResultSet rsJS = stmtJS.executeQuery();
            
            while (rsJS.next()) {
                int id = rsJS.getInt("id_utilizador");
                String tel = rsJS.getString("telefone") != null ? rsJS.getString("telefone") : "";
                String dataNasc = rsJS.getString("data_nascimento") != null ? rsJS.getString("data_nascimento") : "";
%>
  utilizadoresDados[<%= id %>] = {
    telefone: '<%= tel %>',
    dataNascimento: '<%= dataNasc %>'
  };
<%
            }
            rsJS.close();
            stmtJS.close();
            connJS.close();
        } catch (Exception e) {
            // Erro ao carregar dados
        }
    }
%>
  
  // Função para carregar dados do utilizador selecionado (para ADMIN)
  function carregarDadosUtilizador(idUtilizador) {
    if (idUtilizador && utilizadoresDados[idUtilizador]) {
      const dados = utilizadoresDados[idUtilizador];
      document.getElementById('phone').value = dados.telefone;
      document.getElementById('birthDate').value = dados.dataNascimento;
      
      // Animação de preenchimento
      document.getElementById('phone').style.animation = 'pulse 0.5s ease';
      document.getElementById('birthDate').style.animation = 'pulse 0.5s ease';
    }
  }

  // ABRE O MODAL AUTOMATICAMENTE AO CARREGAR A PÁGINA
  window.addEventListener('load', function() {
    document.getElementById('modalSocio').style.display = 'flex';
    document.body.style.overflow = 'hidden';
  });

  function closeModal() {
    const modal = document.getElementById('modalSocio');
    modal.style.animation = 'fadeOut 0.3s ease';
    setTimeout(() => {
      modal.style.display = 'none';
      document.body.style.overflow = 'auto';
      modal.style.animation = '';
    }, 300);
  }

  // Fechar modal ao clicar fora
  document.getElementById('modalSocio').addEventListener('click', function(e) {
    if (e.target === this) {
      closeModal();
    }
  });

  // Fechar modal com ESC
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
      closeModal();
    }
  });

  // Auto-fechar após sucesso e redirecionar para perfil
  <% if (tipoMensagem.equals("success")) { %>
    setTimeout(() => {
      window.location.href = 'perfil.jsp';
    }, 3000);
  <% } %>

  // Validação do telemóvel
  document.getElementById('phone').addEventListener('input', function(e) {
    this.value = this.value.replace(/[^0-9]/g, '');
    if (this.value.length > 9) {
      this.value = this.value.slice(0, 9);
    }
  });

  // Validação da data de nascimento (maior de idade)
  document.getElementById('birthDate').addEventListener('change', function() {
    const hoje = new Date();
    const dataNasc = new Date(this.value);
    let idade = hoje.getFullYear() - dataNasc.getFullYear();
    const m = hoje.getMonth() - dataNasc.getMonth();
    
    if (m < 0 || (m === 0 && hoje.getDate() < dataNasc.getDate())) {
      idade--;
    }
    
    if (idade < 18) {
      alert('⚠️ Deves ter pelo menos 18 anos para te tornares sócio!');
      this.value = '';
    }
  });
  
  // Adicionar animações
  const style = document.createElement('style');
  style.textContent = `
    @keyframes fadeOut {
      from { opacity: 1; }
      to { opacity: 0; }
    }
    @keyframes pulse {
      0%, 100% { transform: scale(1); }
      50% { transform: scale(1.05); }
    }
  `;
  document.head.appendChild(style);
</script>