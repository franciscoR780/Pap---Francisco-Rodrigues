<%--
    Document   : comprarBilhete
    Created on : 30/10/2025, 15:09:03
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Properties" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>
<%
    // Verificar sessão
    Integer idUtilizador = (Integer) session.getAttribute("id_utilizador");
    String primeiroNome = (String) session.getAttribute("primeiro_nome");
    String ultimoNome = (String) session.getAttribute("ultimo_nome");
    String emailUtilizador = (String) session.getAttribute("email");
    Boolean isAdmin = (Boolean) session.getAttribute("is_admin");
    
    if (isAdmin == null) isAdmin = false;
    boolean estaLogado = (idUtilizador != null);
    
    // Buscar telefone do utilizador da base de dados
    String telefoneUtilizador = null;
    
    if (estaLogado) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection connUser = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
            PreparedStatement pstmtUser = connUser.prepareStatement(
                "SELECT telefone FROM t_utilizadores WHERE id_utilizador = ?");
            pstmtUser.setInt(1, idUtilizador);
            ResultSet rsUser = pstmtUser.executeQuery();
            
            if (rsUser.next()) {
                telefoneUtilizador = rsUser.getString("telefone");
            }
            
            rsUser.close();
            pstmtUser.close();
            connUser.close();
        } catch (Exception e) {
            out.println("<!-- Erro ao buscar telefone: " + e.getMessage() + " -->");
        }
    }
    
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
        } catch (Exception e) {}
    }
    
    // Obter ID do evento
    String idEventoParam = request.getParameter("id_evento");
    if (idEventoParam == null || idEventoParam.isEmpty()) {
        response.sendRedirect("Bilheteria.jsp");
        return;
    }
    
    int idEvento = Integer.parseInt(idEventoParam);
    
    // Processar compra
    String mensagem = "";
    String tipoMensagem = "";
    
    if (request.getMethod().equals("POST")) {
        String acao = request.getParameter("acao");
        
        if ("comprar".equals(acao)) {
            int qtdNormal = Integer.parseInt(request.getParameter("qtd_normal"));
            int qtdSocio = Integer.parseInt(request.getParameter("qtd_socio"));
            int qtdEstudante = Integer.parseInt(request.getParameter("qtd_estudante"));
            int qtdCrianca = Integer.parseInt(request.getParameter("qtd_crianca"));
            
            int totalBilhetes = qtdNormal + qtdSocio + qtdEstudante + qtdCrianca;
            
            if (totalBilhetes == 0) {
                mensagem = "Selecione pelo menos 1 bilhete!";
                tipoMensagem = "erro";
            } else {
                String nomeTitular = request.getParameter("nome_titular");
                String emailTitular = request.getParameter("email_titular");
                String telefoneTitular = request.getParameter("telefone_titular");
                String metodoPagamento = request.getParameter("metodo_pagamento");
                
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                    
                    // Buscar dados do evento para o email
                    PreparedStatement eventoStmt = conn.prepareStatement(
                        "SELECT e.nome_evento, e.local_evento, e.data_evento, " +
                        "ec.nome_equipa AS equipa_casa, ef.nome_equipa AS equipa_fora " +
                        "FROM t_eventos e " +
                        "INNER JOIN t_equipas ec ON e.id_equipa_casa = ec.id_equipa " +
                        "LEFT JOIN t_equipas ef ON e.id_equipa_fora = ef.id_equipa " +
                        "WHERE e.id_evento = ?");
                    eventoStmt.setInt(1, idEvento);
                    ResultSet eventoRs = eventoStmt.executeQuery();
                    
                    String nomeEvento = "";
                    String equipaCasa = "";
                    String equipaFora = "";
                    String localEvento = "";
                    Timestamp dataEvento = null;
                    
                    if (eventoRs.next()) {
                        nomeEvento = eventoRs.getString("nome_evento");
                        equipaCasa = eventoRs.getString("equipa_casa");
                        equipaFora = eventoRs.getString("equipa_fora");
                        localEvento = eventoRs.getString("local_evento");
                        dataEvento = eventoRs.getTimestamp("data_evento");
                    }
                    eventoRs.close();
                    eventoStmt.close();
                    
                    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy 'às' HH:mm");
                    
                    // Verificar disponibilidade
                    PreparedStatement checkStmt = conn.prepareStatement(
                        "SELECT capacidade_total - bilhetes_vendidos as disponiveis FROM t_eventos WHERE id_evento = ?");
                    checkStmt.setInt(1, idEvento);
                    ResultSet checkRs = checkStmt.executeQuery();
                    
                    if (checkRs.next()) {
                        int disponiveis = checkRs.getInt("disponiveis");
                        
                        if (totalBilhetes > disponiveis) {
                            mensagem = "Apenas existem " + disponiveis + " bilhetes disponíveis!";
                            tipoMensagem = "erro";
                        } else {
                            // Buscar preços do evento
                            PreparedStatement precosStmt = conn.prepareStatement(
                                "SELECT preco_normal, preco_socio, preco_estudante, preco_crianca FROM t_eventos WHERE id_evento = ?");
                            precosStmt.setInt(1, idEvento);
                            ResultSet precosRs = precosStmt.executeQuery();
                            
                            if (precosRs.next()) {
                                double precoNormal = precosRs.getDouble("preco_normal");
                                double precoSocio = precosRs.getDouble("preco_socio");
                                double precoEstudante = precosRs.getDouble("preco_estudante");
                                double precoCrianca = precosRs.getDouble("preco_crianca");
                                
                                double valorTotal = (qtdNormal * precoNormal) + 
                                                  (qtdSocio * precoSocio) + 
                                                  (qtdEstudante * precoEstudante) + 
                                                  (qtdCrianca * precoCrianca);
                                
                                // Criar venda
                                String numeroVenda = "VB" + System.currentTimeMillis();
                                
                                PreparedStatement vendaStmt = conn.prepareStatement(
                                    "INSERT INTO t_vendas_bilhetes (id_utilizador, numero_venda, data_venda, quantidade_bilhetes, valor_total, metodo_pagamento, estado_pagamento, email_envio) VALUES (?, ?, NOW(), ?, ?, ?, 'pendente', ?)",
                                    Statement.RETURN_GENERATED_KEYS);
                                
                                vendaStmt.setObject(1, estaLogado ? idUtilizador : null);
                                vendaStmt.setString(2, numeroVenda);
                                vendaStmt.setInt(3, totalBilhetes);
                                vendaStmt.setDouble(4, valorTotal);
                                vendaStmt.setString(5, metodoPagamento);
                                vendaStmt.setString(6, emailTitular);
                                
                                vendaStmt.executeUpdate();
                                ResultSet generatedKeys = vendaStmt.getGeneratedKeys();
                                int idVenda = 0;
                                if (generatedKeys.next()) {
                                    idVenda = generatedKeys.getInt(1);
                                }
                                
                                // Inserir bilhetes individuais
                                String[] tipos = {"normal", "socio", "estudante", "crianca"};
                                int[] quantidades = {qtdNormal, qtdSocio, qtdEstudante, qtdCrianca};
                                double[] precos = {precoNormal, precoSocio, precoEstudante, precoCrianca};
                                
                                int totalInseridos = 0;
                                
                                for (int i = 0; i < tipos.length; i++) {
                                    for (int j = 0; j < quantidades[i]; j++) {
                                        String codigoBilhete = "SCRT" + System.currentTimeMillis() + "-" + totalInseridos;
                                        String numeroBilhete = "B" + String.format("%08d", (int)(Math.random() * 99999999));
                                        
                                        PreparedStatement bilheteStmt = conn.prepareStatement(
                                            "INSERT INTO t_bilhetes (id_evento, id_utilizador, codigo_bilhete, numero_bilhete, nome_titular, email_titular, telefone_titular, tipo_bilhete, setor, preco_pago, estado_bilhete, data_reserva, data_venda, metodo_pagamento) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Geral', ?, 'vendido', NOW(), NOW(), ?)");
                                        
                                        bilheteStmt.setInt(1, idEvento);
                                        bilheteStmt.setObject(2, estaLogado ? idUtilizador : null);
                                        bilheteStmt.setString(3, codigoBilhete);
                                        bilheteStmt.setString(4, numeroBilhete);
                                        bilheteStmt.setString(5, nomeTitular);
                                        bilheteStmt.setString(6, emailTitular);
                                        bilheteStmt.setString(7, telefoneTitular);
                                        bilheteStmt.setString(8, tipos[i]);
                                        bilheteStmt.setDouble(9, precos[i]);
                                        bilheteStmt.setString(10, metodoPagamento);
                                        
                                        bilheteStmt.executeUpdate();
                                        bilheteStmt.close();
                                        
                                        totalInseridos++;
                                        
                                        // Pequeno delay para garantir timestamps únicos
                                        try { Thread.sleep(1); } catch (Exception ex) {}
                                    }
                                }
                                
                                // Atualizar contador do evento
                                PreparedStatement updateStmt = conn.prepareStatement(
                                    "UPDATE t_eventos SET bilhetes_vendidos = bilhetes_vendidos + ? WHERE id_evento = ?");
                                updateStmt.setInt(1, totalBilhetes);
                                updateStmt.setInt(2, idEvento);
                                updateStmt.executeUpdate();
                                updateStmt.close();
                                
                                // ENVIAR EMAIL COM RECIBO
                                try {
                                    enviarEmailRecibo(emailTitular, nomeTitular, numeroVenda, 
                                                     nomeEvento, equipaCasa, equipaFora, 
                                                     sdf.format(dataEvento), localEvento,
                                                     qtdNormal, qtdSocio, qtdEstudante, qtdCrianca,
                                                     precoNormal, precoSocio, precoEstudante, precoCrianca,
                                                     valorTotal, metodoPagamento);
                                } catch (Exception emailEx) {
                                    out.println("<!-- Erro ao enviar email: " + emailEx.getMessage() + " -->");
                                }
                                
                                mensagem = "Compra realizada com sucesso! Número da venda: " + numeroVenda + ". Recibo enviado para o seu email!";
                                tipoMensagem = "sucesso";
                                
                                // Redirecionar após 3 segundos
                                response.setHeader("Refresh", "3;URL=confirmacaoBilhete.jsp?numero_venda=" + numeroVenda);
                            }
                            
                            precosRs.close();
                            precosStmt.close();
                        }
                    }
                    
                    checkRs.close();
                    checkStmt.close();
                    conn.close();
                    
                } catch (Exception e) {
                    mensagem = "Erro ao processar compra: " + e.getMessage();
                    tipoMensagem = "erro";
                }
            }
        }
    }
%>
<%!
    // MÉTODO PARA ENVIAR EMAIL COM RECIBO
    private void enviarEmailRecibo(String destinatario, String nomeCliente, String numeroVenda,
                                   String nomeEvento, String equipaCasa, String equipaFora,
                                   String dataEvento, String localEvento,
                                   int qtdNormal, int qtdSocio, int qtdEstudante, int qtdCrianca,
                                   double precoNormal, double precoSocio, double precoEstudante, double precoCrianca,
                                   double valorTotal, String metodoPagamento) throws Exception {
        
        // Configurações do servidor SMTP do Gmail
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        
        final String username = "scrxllclaude123@gmail.com";
        final String password = "pvbw tjwi jnzi mrgc";
        
        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });
        
        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(username, "SC Rio Tinto"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destinatario));
            message.setSubject("🎫 Recibo de Compra de Bilhetes - " + numeroVenda);
            
            // Construir HTML do email
            StringBuilder html = new StringBuilder();
            html.append("<!DOCTYPE html>");
            html.append("<html>");
            html.append("<head>");
            html.append("<meta charset='UTF-8'>");
            html.append("<style>");
            html.append("body { font-family: 'Arial', sans-serif; background: #f4f4f4; margin: 0; padding: 0; }");
            html.append(".container { max-width: 650px; margin: 30px auto; background: white; border-radius: 15px; overflow: hidden; box-shadow: 0 10px 40px rgba(0,0,0,0.1); }");
            html.append(".header { background: linear-gradient(135deg, #FFD700 0%, #FFA000 100%); padding: 40px 30px; text-align: center; }");
            html.append(".header h1 { color: #0a0a0a; margin: 0; font-size: 28px; font-weight: 900; text-transform: uppercase; }");
            html.append(".header p { color: #0a0a0a; margin: 10px 0 0 0; font-size: 16px; opacity: 0.9; }");
            html.append(".content { padding: 40px 30px; }");
            html.append(".section { margin-bottom: 30px; }");
            html.append(".section-title { font-size: 18px; font-weight: 700; color: #0a0a0a; margin-bottom: 15px; padding-bottom: 10px; border-bottom: 3px solid #FFD700; }");
            html.append(".info-row { display: flex; justify-content: space-between; padding: 12px 0; border-bottom: 1px solid #f0f0f0; }");
            html.append(".info-label { color: #666; font-weight: 600; }");
            html.append(".info-value { color: #0a0a0a; font-weight: 700; text-align: right; }");
            html.append(".evento-box { background: linear-gradient(135deg, #0a0a0a 0%, #1a1a1a 100%); color: white; padding: 25px; border-radius: 12px; margin-bottom: 25px; }");
            html.append(".evento-box h2 { margin: 0 0 15px 0; color: #FFD700; font-size: 22px; }");
            html.append(".evento-detail { display: flex; align-items: center; margin-bottom: 10px; font-size: 15px; }");
            html.append(".evento-detail i { color: #FFD700; margin-right: 10px; width: 20px; }");
            html.append(".bilhete-item { background: #f8f9fa; padding: 15px; border-radius: 10px; margin-bottom: 10px; display: flex; justify-content: space-between; align-items: center; }");
            html.append(".bilhete-nome { font-weight: 700; color: #0a0a0a; }");
            html.append(".bilhete-preco { font-size: 18px; font-weight: 900; color: #FFD700; }");
            html.append(".total-box { background: linear-gradient(135deg, rgba(255,215,0,0.1) 0%, rgba(255,215,0,0.2) 100%); padding: 25px; border-radius: 12px; margin-top: 25px; text-align: center; border: 3px solid #FFD700; }");
            html.append(".total-label { font-size: 18px; color: #666; margin-bottom: 10px; }");
            html.append(".total-value { font-size: 36px; font-weight: 900; color: #FFD700; }");
            html.append(".footer { background: #0a0a0a; color: white; text-align: center; padding: 30px; }");
            html.append(".footer p { margin: 5px 0; font-size: 14px; opacity: 0.8; }");
            html.append(".numero-venda { background: #FFD700; color: #0a0a0a; padding: 15px 25px; border-radius: 50px; display: inline-block; font-weight: 900; font-size: 18px; margin: 20px 0; letter-spacing: 2px; }");
            html.append("</style>");
            html.append("</head>");
            html.append("<body>");
            
            html.append("<div class='container'>");
            
            // Header
            html.append("<div class='header'>");
            html.append("<h1>🎫 RECIBO DE COMPRA</h1>");
            html.append("<p>SC Rio Tinto - Bilheteira Online</p>");
            html.append("<div class='numero-venda'>").append(numeroVenda).append("</div>");
            html.append("</div>");
            
            // Content
            html.append("<div class='content'>");
            
            // Saudação
            html.append("<p style='font-size: 16px; margin-bottom: 25px;'>Olá <strong>").append(nomeCliente).append("</strong>,</p>");
            html.append("<p style='font-size: 15px; color: #666; margin-bottom: 30px;'>Obrigado pela sua compra! Aqui está o recibo detalhado dos seus bilhetes.</p>");
            
            // Evento
            html.append("<div class='evento-box'>");
            html.append("<h2>").append(nomeEvento).append("</h2>");
            html.append("<div class='evento-detail'><span>⚽</span> ").append(equipaCasa).append(" vs ").append(equipaFora != null ? equipaFora : "A definir").append("</div>");
            html.append("<div class='evento-detail'><span>📅</span> ").append(dataEvento).append("</div>");
            html.append("<div class='evento-detail'><span>📍</span> ").append(localEvento).append("</div>");
            html.append("</div>");
            
            // Bilhetes
            html.append("<div class='section'>");
            html.append("<div class='section-title'>🎟️ Bilhetes Adquiridos</div>");
            
            if (qtdNormal > 0) {
                html.append("<div class='bilhete-item'>");
                html.append("<div>");
                html.append("<div class='bilhete-nome'>Normal</div>");
                html.append("<div style='color: #666; font-size: 14px;'>Quantidade: ").append(qtdNormal).append("x</div>");
                html.append("</div>");
                html.append("<div class='bilhete-preco'>").append(String.format("%.2f€", qtdNormal * precoNormal)).append("</div>");
                html.append("</div>");
            }
            
            if (qtdSocio > 0) {
                html.append("<div class='bilhete-item'>");
                html.append("<div>");
                html.append("<div class='bilhete-nome'>Sócio</div>");
                html.append("<div style='color: #666; font-size: 14px;'>Quantidade: ").append(qtdSocio).append("x</div>");
                html.append("</div>");
                html.append("<div class='bilhete-preco'>").append(String.format("%.2f€", qtdSocio * precoSocio)).append("</div>");
                html.append("</div>");
            }
            
            if (qtdEstudante > 0) {
                html.append("<div class='bilhete-item'>");
                html.append("<div>");
                html.append("<div class='bilhete-nome'>Estudante</div>");
                html.append("<div style='color: #666; font-size: 14px;'>Quantidade: ").append(qtdEstudante).append("x</div>");
                html.append("</div>");
                html.append("<div class='bilhete-preco'>").append(String.format("%.2f€", qtdEstudante * precoEstudante)).append("</div>");
                html.append("</div>");
            }
            
            if (qtdCrianca > 0) {
                html.append("<div class='bilhete-item'>");
                html.append("<div>");
                html.append("<div class='bilhete-nome'>Criança</div>");
                html.append("<div style='color: #666; font-size: 14px;'>Quantidade: ").append(qtdCrianca).append("x</div>");
                html.append("</div>");
                html.append("<div class='bilhete-preco'>").append(String.format("%.2f€", qtdCrianca * precoCrianca)).append("</div>");
                html.append("</div>");
            }
            
            html.append("</div>");
            
            // Detalhes do Pagamento
            html.append("<div class='section'>");
            html.append("<div class='section-title'>💳 Detalhes do Pagamento</div>");
            html.append("<div class='info-row'>");
            html.append("<span class='info-label'>Método de Pagamento:</span>");
            html.append("<span class='info-value'>").append(metodoPagamento.toUpperCase()).append("</span>");
            html.append("</div>");
            html.append("<div class='info-row'>");
            html.append("<span class='info-label'>Data da Compra:</span>");
            html.append("<span class='info-value'>").append(new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date())).append("</span>");
            html.append("</div>");
            html.append("</div>");
            
            // Total
            html.append("<div class='total-box'>");
            html.append("<div class='total-label'>VALOR TOTAL PAGO</div>");
            html.append("<div class='total-value'>").append(String.format("%.2f€", valorTotal)).append("</div>");
            html.append("</div>");
            
            // Instruções
            html.append("<div style='background: #FFF8DC; padding: 20px; border-radius: 10px; border-left: 5px solid #FFD700; margin-top: 30px;'>");
            html.append("<h3 style='margin: 0 0 10px 0; color: #0a0a0a; font-size: 16px;'>📋 Instruções Importantes</h3>");
            html.append("<ul style='margin: 0; padding-left: 20px; color: #666; font-size: 14px;'>");
            html.append("<li style='margin-bottom: 8px;'>Guarde este email como comprovativo de compra</li>");
            html.append("<li style='margin-bottom: 8px;'>Apresente o número da venda na entrada do estádio</li>");
            html.append("<li style='margin-bottom: 8px;'>Chegue com antecedência para evitar filas</li>");
            html.append("<li>Em caso de dúvidas, contacte-nos através do nosso site</li>");
            html.append("</ul>");
            html.append("</div>");
            
            html.append("</div>");
            
            // Footer
            html.append("<div class='footer'>");
            html.append("<h3 style='margin: 0 0 15px 0; color: #FFD700;'>SC RIO TINTO</h3>");
            html.append("<p>Estádio Cidade de Rio Tinto</p>");
            html.append("<p>Rua do Clube, 123 - 4435-123 Rio Tinto</p>");
            html.append("<p style='margin-top: 15px;'>🌐 www.scriotinto.pt | 📧 geral@scriotinto.pt</p>");
            html.append("<p style='margin-top: 20px; font-size: 12px; opacity: 0.6;'>Este é um email automático. Por favor não responda.</p>");
            html.append("</div>");
            
            html.append("</div>");
            html.append("</body>");
            html.append("</html>");
            
            message.setContent(html.toString(), "text/html; charset=utf-8");
            
            Transport.send(message);
            
        } catch (Exception e) {
            throw new Exception("Erro ao enviar email: " + e.getMessage());
        }
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Comprar Bilhetes - SC Rio Tinto</title>
    <link href="css/CssComprarBilhete.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>
<body>
    <header>
        <div class="logo-container" onclick="window.location.href='index.htm'">
            <div class="logo-icon">SC</div>
            <span>Rio Tinto</span>
        </div>
    </header>

    <div class="container">
        <a href="Bilheteria.jsp" class="btn-voltar">
            <i class="fas fa-arrow-left"></i>
            Voltar aos Eventos
        </a>

        <% if (!mensagem.isEmpty()) { %>
            <div class="alert alert-<%= tipoMensagem %>">
                <i class="fas fa-<%= tipoMensagem.equals("sucesso") ? "check-circle" : "exclamation-triangle" %>"></i>
                <%= mensagem %>
            </div>
        <% } %>

        <%
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                
                PreparedStatement pstmt = conn.prepareStatement(
                    "SELECT e.*, ec.nome_equipa AS equipa_casa, ef.nome_equipa AS equipa_fora " +
                    "FROM t_eventos e " +
                    "INNER JOIN t_equipas ec ON e.id_equipa_casa = ec.id_equipa " +
                    "LEFT JOIN t_equipas ef ON e.id_equipa_fora = ef.id_equipa " +
                    "WHERE e.id_evento = ?");
                pstmt.setInt(1, idEvento);
                ResultSet rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    String nomeEvento = rs.getString("nome_evento");
                    String equipaCasa = rs.getString("equipa_casa");
                    String equipaFora = rs.getString("equipa_fora");
                    String localEvento = rs.getString("local_evento");
                    Timestamp dataEvento = rs.getTimestamp("data_evento");
                    int capacidade = rs.getInt("capacidade_total");
                    int vendidos = rs.getInt("bilhetes_vendidos");
                    double precoNormal = rs.getDouble("preco_normal");
                    double precoSocio = rs.getDouble("preco_socio");
                    double precoEstudante = rs.getDouble("preco_estudante");
                    double precoCrianca = rs.getDouble("preco_crianca");
                    
                    int disponiveis = capacidade - vendidos;
                    
                    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy 'às' HH:mm");
        %>
                    <div class="evento-info-card">
                        <h2><%= nomeEvento %></h2>
                        <div class="evento-detail">
                            <i class="fas fa-users"></i>
                            <%= equipaCasa %> vs <%= equipaFora != null ? equipaFora : "A definir" %>
                        </div>
                        <div class="evento-detail">
                            <i class="fas fa-calendar-alt"></i>
                            <%= sdf.format(dataEvento) %>
                        </div>
                        <div class="evento-detail">
                            <i class="fas fa-map-marker-alt"></i>
                            <%= localEvento %>
                        </div>
                        <div class="evento-detail">
                            <i class="fas fa-ticket-alt"></i>
                            <%= disponiveis %> bilhetes disponíveis
                        </div>
                    </div>

                    <form method="POST" id="formCompra">
                        <input type="hidden" name="acao" value="comprar">
                        
                        <div class="compra-layout">
                            <div>
                                <div class="form-section">
                                    <h3>
                                        <i class="fas fa-ticket-alt"></i>
                                        Selecionar Bilhetes
                                    </h3>
                                    
                                    <div class="bilhete-selector">
                                        <div class="bilhete-tipo">
                                            <div class="bilhete-info">
                                                <div class="bilhete-nome">Normal</div>
                                                <div class="bilhete-preco"><%= String.format("%.2f€", precoNormal) %></div>
                                            </div>
                                            <div class="quantidade-control">
                                                <button type="button" class="btn-qtd" onclick="alterarQtd('normal', -1)">-</button>
                                                <span class="qtd-display" id="qtd_normal_display">0</span>
                                                <button type="button" class="btn-qtd" onclick="alterarQtd('normal', 1)">+</button>
                                                <input type="hidden" name="qtd_normal" id="qtd_normal" value="0">
                                            </div>
                                        </div>

                                        <div class="bilhete-tipo <%= !jaSocio ? "bilhete-bloqueado" : "" %>">
                                        <div class="bilhete-info">
                                            <div class="bilhete-nome">
                                                Sócio 
                                                <% if (!estaLogado) { %>
                                                    <span class="badge-info" title="Faça login para verificar">🔒</span>
                                                <% } else if (!jaSocio) { %>
                                                    <span class="badge-bloqueado" title="Apenas para sócios">❌ Não disponível</span>
                                                <% } else { %>
                                                    <span class="badge-socio" title="Sócio nº <%= numeroSocio %>">✓ Sócio</span>
                                                <% } %>
                                            </div>
                                            <div class="bilhete-preco"><%= String.format("%.2f€", precoSocio) %></div>
                                            <% if (!estaLogado) { %>
                                                <small style="color: #ef4444; font-weight: 600; display: block; margin-top: 0.5rem;">
                                                    <i class="fas fa-exclamation-circle"></i> Faça login para comprar
                                                </small>
                                            <% } else if (!jaSocio) { %>
                                                <small style="color: #ef4444; font-weight: 600; display: block; margin-top: 0.5rem;">
                                                    <i class="fas fa-times-circle"></i> Exclusivo para sócios
                                                </small>
                                            <% } %>
                                        </div>
                                        <div class="quantidade-control">
                                            <button type="button" class="btn-qtd" 
                                                    onclick="alterarQtd('socio', -1)" 
                                                    <%= !estaLogado || !jaSocio ? "disabled" : "" %>>-</button>
                                            <span class="qtd-display" id="qtd_socio_display">0</span>
                                            <button type="button" class="btn-qtd" 
                                                    onclick="alterarQtd('socio', 1)" 
                                                    <%= !estaLogado || !jaSocio ? "disabled" : "" %>>+</button>
                                            <input type="hidden" name="qtd_socio" id="qtd_socio" value="0">
                                        </div>
                                    </div>

                                        <div class="bilhete-tipo">
                                            <div class="bilhete-info">
                                                <div class="bilhete-nome">Estudante</div>
                                                <div class="bilhete-preco"><%= String.format("%.2f€", precoEstudante) %></div>
                                            </div>
                                            <div class="quantidade-control">
                                                <button type="button" class="btn-qtd" onclick="alterarQtd('estudante', -1)">-</button>
                                                <span class="qtd-display" id="qtd_estudante_display">0</span>
                                                <button type="button" class="btn-qtd" onclick="alterarQtd('estudante', 1)">+</button>
                                                <input type="hidden" name="qtd_estudante" id="qtd_estudante" value="0">
                                            </div>
                                        </div>

                                        <div class="bilhete-tipo">
                                            <div class="bilhete-info">
                                                <div class="bilhete-nome">Criança</div>
                                                <div class="bilhete-preco"><%= String.format("%.2f€", precoCrianca) %></div>
                                            </div>
                                            <div class="quantidade-control">
                                                <button type="button" class="btn-qtd" onclick="alterarQtd('crianca', -1)">-</button>
                                                <span class="qtd-display" id="qtd_crianca_display">0</span>
                                                <button type="button" class="btn-qtd" onclick="alterarQtd('crianca', 1)">+</button>
                                                <input type="hidden" name="qtd_crianca" id="qtd_crianca" value="0">
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="form-section" style="margin-top: 2rem;">
                                    <h3>
                                        <i class="fas fa-chair"></i>
                                        Selecionar Lugares
                                    </h3>
                                    
                                    <div style="background: #f8f9fa; padding: 1.5rem; border-radius: 15px; margin-bottom: 1rem;">
                                        <div style="text-align: center; margin-bottom: 1.5rem;">
                                            <div style="background: var(--amarelo); padding: 0.5rem; border-radius: 8px; display: inline-block; font-weight: 700; margin-bottom: 1rem;">
                                                <i class="fas fa-futbol"></i> CAMPO
                                            </div>
                                        </div>
                                        
                                        <div style="display: flex; gap: 1rem; justify-content: center; margin-bottom: 1rem; font-size: 0.85rem;">
                                            <div><span style="display: inline-block; width: 20px; height: 20px; background: #10B981; border-radius: 4px; vertical-align: middle;"></span> Disponível</div>
                                            <div><span style="display: inline-block; width: 20px; height: 20px; background: var(--amarelo); border-radius: 4px; vertical-align: middle;"></span> Selecionado</div>
                                            <div><span style="display: inline-block; width: 20px; height: 20px; background: #e0e0e0; border-radius: 4px; vertical-align: middle;"></span> Ocupado</div>
                                        </div>

                                        <div style="max-height: 400px; overflow-y: auto; padding: 1rem; background: white; border-radius: 10px;">
                                            <div id="mapa-lugares" style="display: grid; grid-template-columns: repeat(20, 1fr); gap: 8px;"></div>
                                        </div>

                                        <div style="margin-top: 1rem; padding: 1rem; background: rgba(255, 215, 0, 0.1); border-radius: 8px;">
                                            <strong>Lugares Selecionados:</strong>
                                            <div id="lugares-selecionados" style="margin-top: 0.5rem; color: var(--amarelo); font-weight: 700;">
                                                Nenhum lugar selecionado
                                            </div>
                                        </div>
                                        <input type="hidden" name="lugares_selecionados" id="lugares_selecionados_input" value="">
                                    </div>
                                </div>

                                <div class="form-section" style="margin-top: 2rem;">
                                    <h3>
                                        <i class="fas fa-user"></i>
                                        Dados do Titular
                                    </h3>
                                    
                                    <div class="form-group">
                                        <label>Nome Completo *</label>
                                        <input type="text" name="nome_titular" required 
                                               value="<%= estaLogado ? primeiroNome + " " + ultimoNome : "" %>">
                                    </div>

                                    <div class="form-group">
                                        <label>Email *</label>
                                        <input type="email" name="email_titular" required 
                                               value="<%= estaLogado && emailUtilizador != null ? emailUtilizador : "" %>">
                                    </div>

                                    <div class="form-group">
                                        <label>Telefone *</label>
                                        <input type="tel" name="telefone_titular" required 
                                               value="<%= estaLogado && telefoneUtilizador != null ? telefoneUtilizador : "" %>">
                                    </div>

                                    <div class="form-group">
                                        <label>Método de Pagamento *</label>
                                        <select name="metodo_pagamento" required>
                                            <option value="">Selecione...</option>
                                            <option value="multibanco">Multibanco</option>
                                            <option value="mbway">MBWay</option>
                                            <option value="cartao">Cartão de Crédito</option>
                                            <option value="paypal">PayPal</option>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <div>
                                <div class="resumo-card">
                                    <h3>Resumo da Compra</h3>
                                    
                                    <div id="resumo-bilhetes"></div>

                                    <div class="resumo-total">
                                        <span>Total:</span>
                                        <span id="valor-total"></span>
                                    </div>

                                    <button type="submit" class="btn-finalizar" id="btnFinalizar" disabled>
                                        <i class="fas fa-shopping-cart"></i>
                                        Finalizar Compra
                                    </button>

                                    <div style="text-align: center; margin-top: 1rem; font-size: 0.85rem; color: #666;">
                                        <i class="fas fa-lock"></i>
                                        Compra 100% segura
                                    </div>
                                </div>
                            </div>
                        </div>
                    </form>

                    <script>
                        const precos = {
                            normal: <%= precoNormal %>,
                            socio: <%= precoSocio %>,
                            estudante: <%= precoEstudante %>,
                            crianca: <%= precoCrianca %>
                        };

                        const disponiveis = <%= disponiveis %>;

                        const quantidades = {
                            normal: 0,
                            socio: 0,
                            estudante: 0,
                            crianca: 0
                        };

                        let lugaresSelecionados = [];
                        let lugaresOcupados = [];

                        // Gerar lugares ocupados aleatoriamente (simulação)
                        function gerarLugaresOcupados() {
                            const numOcupados = Math.floor(Math.random() * 200) + 100;
                            const ocupados = new Set();
                            while (ocupados.size < numOcupados) {
                                ocupados.add(Math.floor(Math.random() * 1000) + 1);
                            }
                            return Array.from(ocupados);
                        }

                        lugaresOcupados = gerarLugaresOcupados();

                        // Criar mapa de lugares
                        function criarMapaLugares() {
                            const mapa = document.getElementById('mapa-lugares');
                            mapa.innerHTML = '';

                            for (let i = 1; i <= 1000; i++) {
                                const lugar = document.createElement('div');
                                lugar.className = 'lugar-assento';
                                lugar.textContent = i;
                                lugar.dataset.lugar = i;

                                if (lugaresOcupados.includes(i)) {
                                    lugar.classList.add('ocupado');
                                } else {
                                    lugar.addEventListener('click', () => selecionarLugar(i, lugar));
                                }

                                mapa.appendChild(lugar);
                            }
                        }

                        function selecionarLugar(numero, elemento) {
                            const totalBilhetes = Object.values(quantidades).reduce((a, b) => a + b, 0);

                            if (lugaresSelecionados.includes(numero)) {
                                lugaresSelecionados = lugaresSelecionados.filter(l => l !== numero);
                                elemento.classList.remove('selecionado');
                            } else {
                                if (lugaresSelecionados.length >= totalBilhetes) {
                                    alert('Você já selecionou ' + totalBilhetes + ' lugar(es). Adicione mais bilhetes ou desselecione lugares.');
                                    return;
                                }
                                lugaresSelecionados.push(numero);
                                elemento.classList.add('selecionado');
                            }

                            atualizarLugaresSelecionados();
                        }

                        function atualizarLugaresSelecionados() {
                            const div = document.getElementById('lugares-selecionados');
                            const input = document.getElementById('lugares_selecionados_input');

                            if (lugaresSelecionados.length === 0) {
                                div.innerHTML = 'Nenhum lugar selecionado';
                                input.value = '';
                            } else {
                                lugaresSelecionados.sort((a, b) => a - b);
                                div.innerHTML = 'Lugares: ' + lugaresSelecionados.join(', ');
                                input.value = lugaresSelecionados.join(',');
                            }
                        }

                        function alterarQtd(tipo, delta) {
                            const totalAtual = Object.values(quantidades).reduce((a, b) => a + b, 0);
                            
                            if (delta > 0 && totalAtual >= disponiveis) {
                                alert('Não há mais bilhetes disponíveis!');
                                return;
                            }

                            const novaQtd = Math.max(0, quantidades[tipo] + delta);
                            
                            if (delta < 0 && lugaresSelecionados.length > 0) {
                                const novoTotal = totalAtual + delta;
                                if (lugaresSelecionados.length > novoTotal) {
                                    const lugarRemovido = lugaresSelecionados.pop();
                                    const elementoLugar = document.querySelector('[data-lugar="' + lugarRemovido + '"]');
                                    if (elementoLugar) {
                                        elementoLugar.classList.remove('selecionado');
                                    }
                                    atualizarLugaresSelecionados();
                                }
                            }

                            quantidades[tipo] = novaQtd;
                            
                            document.getElementById('qtd_' + tipo).value = quantidades[tipo];
                            document.getElementById('qtd_' + tipo + '_display').textContent = quantidades[tipo];
                            
                            atualizarResumo();
                        }

                        function atualizarResumo() {
                            let total = 0;
                            let totalBilhetes = 0;
                            let html = '';

                            const nomes = {
                                normal: 'Normal',
                                socio: 'Sócio',
                                estudante: 'Estudante',
                                crianca: 'Criança'
                            };

                            for (let tipo in quantidades) {
                                if (quantidades[tipo] > 0) {
                                    const subtotal = quantidades[tipo] * precos[tipo];
                                    total += subtotal;
                                    totalBilhetes += quantidades[tipo];
                                    
                                    html += '<div class="resumo-item">';
                                    html += '<span>' + quantidades[tipo] + 'x ' + nomes[tipo] + '</span>';
                                    html += '<span style="font-weight: 700;">' + subtotal.toFixed(2) + '€</span>';
                                    html += '</div>';
                                }
                            }

                            if (html === '') {
                                html = '<div class="resumo-item" style="text-align: center; color: #999; padding: 2rem 0;">';
                                html += '<span>Selecione os bilhetes</span>';
                                html += '</div>';
                            }

                            document.getElementById('resumo-bilhetes').innerHTML = html;
                            document.getElementById('valor-total').innerHTML = total.toFixed(2) + '€';
                            
                            const btnFinalizar = document.getElementById('btnFinalizar');
                            btnFinalizar.disabled = totalBilhetes === 0;
                        }

                        document.getElementById('formCompra').addEventListener('submit', function(e) {
                            const totalBilhetes = Object.values(quantidades).reduce((a, b) => a + b, 0);
                            
                            if (totalBilhetes === 0) {
                                e.preventDefault();
                                alert('Selecione pelo menos 1 bilhete!');
                                return false;
                            }

                            if (lugaresSelecionados.length !== totalBilhetes) {
                                e.preventDefault();
                                alert('Você deve selecionar exatamente ' + totalBilhetes + ' lugar(es)!');
                                return false;
                            }

                            const metodoPagamento = document.querySelector('select[name="metodo_pagamento"]').value;
                            if (!metodoPagamento) {
                                e.preventDefault();
                                alert('Selecione um método de pagamento!');
                                return false;
                            }

                            return confirm('Confirma a compra de ' + totalBilhetes + ' bilhete(s) nos lugares: ' + lugaresSelecionados.join(', ') + '?');
                        });

                        document.addEventListener('DOMContentLoaded', function() {
                            atualizarResumo();
                            criarMapaLugares();
                            
                            const cards = document.querySelectorAll('.form-section, .resumo-card');
                            cards.forEach((card, index) => {
                                card.style.opacity = '0';
                                card.style.transform = 'translateY(30px)';
                                card.style.transition = 'all 0.6s ease';
                                
                                setTimeout(() => {
                                    card.style.opacity = '1';
                                    card.style.transform = 'translateY(0)';
                                }, index * 150);
                            });
                        });
                    </script>
        <%
                } else {
                    out.println("<div class='alert alert-erro'>");
                    out.println("<i class='fas fa-exclamation-triangle'></i>");
                    out.println("Evento não encontrado!");
                    out.println("</div>");
                }
                
                rs.close();
                pstmt.close();
                conn.close();
                
            } catch (Exception e) {
                out.println("<div class='alert alert-erro'>");
                out.println("<i class='fas fa-exclamation-triangle'></i>");
                out.println("Erro ao carregar evento: " + e.getMessage());
                out.println("</div>");
            }
        %>
    </div>
</body>
</html>