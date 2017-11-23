USE [IR]
GO
--truncate table dimVenda

INSERT INTO [dbo].[dimVenda]
           ([is_bileto]
           ,[gateway]
           ,[numero_venda_ir]
           ,[venda_bilheteria_id]
           ,[codigo_gateway]
           ,[nsu_host]
           ,[nsu_sitef]
           ,[paypal_id]
           ,[numero_autorizacao_adquirente]
           ,[data_compra]
           ,[quantidade_ingressos]
           ,[bandeira]
           ,[tipo_cartao]
           ,[nome_forma_pagamento]
           ,[valor_taxa_conveniencia_total]
           ,[valor_taxa_entrega_total]
           ,[valor_juros_total]
           ,[valor_ingressos_ativos_total]
           ,[valor_compra_original_total]
           ,[numero_parcelas]
           ,[numero_cartao]
           ,[nome_portador_cartao]
           ,[status_compra]
           ,[nome_comprador]
           ,[email_comprador]
           ,[facebook_id]
           ,[cpf_comprador]
           ,[telefone_comprador]
           ,[id_usuario]
           ,[ip_comprador]
           ,[plataforma_utilizada]
           ,[id_produtor_evento]
           ,[nome_produtor_evento]
           ,[nome_evento]
           ,[id_evento]
           ,[data_evento]
           ,[nome_local]
           ,[tipo_evento]
           ,[nota_fiscal_estabelecimento_sitef]
           ,[data_venda_completa]
           ,[nomes_precos_ingressos_unicos])

SELECT distinct [is_bileto]
      ,[gateway]
      ,[numero_venda_ir]
      ,[venda_bilheteria_id]
      ,[codigo_gateway]
      ,[nsu_host]
      ,[nsu_sitef]
      ,[paypal_id]
      ,[numero_autorizacao_adquirente]
      ,[data_compra]
      ,[quantidade_ingressos]
      ,[bandeira]
      ,[tipo_cartao]
      ,[nome_forma_pagamento]
      ,[valor_taxa_conveniencia_total]
      ,[valor_taxa_entrega_total]
      ,[valor_juros_total]
      ,[valor_ingressos_ativos_total]
      ,[valor_compra_original_total]
      ,[numero_parcelas]
      ,[numero_cartao]
      ,[nome_portador_cartao]
      ,[status_compra]
      ,[nome_comprador]
      ,[email_comprador]
      ,[facebook_id]
      ,[cpf_comprador]
      ,[telefone_comprador]
      ,[id_usuario]
      ,[ip_comprador]
      ,[plataforma_utilizada]
      ,[id_produtor_evento]
      ,[nome_produtor_evento]
      ,[nome_evento]
      ,[id_evento]
      ,[data_evento]
      ,[nome_local]
      ,[tipo_evento]
      ,[nota_fiscal_estabelecimento_sitef]
      ,[data_venda_completa]
      ,[nomes_precos_ingressos_unicos]
  FROM [dbo].[dsVendaAtivaLegado] a
  left join dimVenda b 


GO

