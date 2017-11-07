USE [IR]
GO

--drop table tmpVendaLegadoAtiva

SELECT [is_bileto] as [isBileto]
      ,[gateway] as [Gateway]
      ,[numero_venda_ir] as [IdVendaIR]
      ,[venda_bilheteria_id] as [IdVendaBilheteria]
      ,[codigo_gateway] as [CodigoGateway]
      ,[nsu_host] as [NSUHost]
      ,[nsu_sitef] as [NSUSitef]
      ,[paypal_id] as [PayPalId]
      ,[numero_autorizacao_adquirente] as [NroAutorizacaoAdquirente]
      ,[data_compra] as [DataCompra]
      ,[quantidade_ingressos] as QtdeIngressos
      ,[bandeira] as Bandeira
      ,[tipo_cartao] as TipoCartao
      ,[nome_forma_pagamento] as NomeFormaPagamento
      ,[valor_taxa_conveniencia_total] as ValorTaxaConvenienciaTotal
      ,[valor_taxa_entrega_total] as ValorTaxaEntregaTotal
      ,[valor_juros_total] as ValorJurosTotal
      ,[valor_ingressos_ativos_total] as ValorIngressosAtivosTotal
      ,[valor_compra_original_total] as ValorVendaTotal
      ,[numero_parcelas] as NumeroParcelas
      ,[numero_cartao] as NumeroCartao
      ,[nome_portador_cartao] as NomePortadorCartao
      ,[status_compra] as StatusCompra
      ,[nome_comprador] as NomeComprador
      ,[email_comprador] as EmailComprador
      ,[facebook_id] as IdFacebook
      ,[cpf_comprador] as CPFComprador
      ,[telefone_comprador] as TelefoneComprador
      ,[id_usuario] as IdUsuario
      ,[ip_comprador] as IpComprador
      ,[plataforma_utilizada] as PlataformaUtilizada
      ,[id_produtor_evento] as IdProdutorEvento
      ,[nome_produtor_evento] as NomeProdutorEvento
      ,[nome_evento] as NomeEvento
      ,[id_evento] as IdEvento
      ,[data_evento] as DataEvento
      ,[nome_local] as NomeLocal
      ,[tipo_evento] as TipoEvento
      ,[nota_fiscal_estabelecimento_sitef] as TextoNotaFiscal
      ,[data_venda_completa] as DataCompleta
      ,[nomes_precos_ingressos_unicos] as NomeTipoDeIngressos
	  ,-1 as IdTransacaoIR
	  ,-1 as IdTransacaoAdquirente
	  ,-1 as IdLoteIR
	into tmpVendaLegadoAtiva
  FROM [dbo].[dsVendaAtivaLegado]
  where data_compra between '6/1/2017' and '7/1/2017'
GO

--===================================================================================
-- LINK ENTRE VENDA E TRANSACAO IR
-- 
-- ToDo: junto atualizar o IdTransacaoAdquirente
--===================================================================================
-- Total 5.714 --> 3.622 (1/6/2017)
-- 157.926 (162723) --> 45.948 (6/2017)
update tmpVendaLegadoAtiva
set IdTransacaoIR = b.IdTransacaoIR, 
IdTransacaoAdquirente = c.IdTransacaoAdquirente
from tmpVendaLegadoAtiva a
inner join dimTransacaoIR b on a.IdVendaIR = b.Localizador
left join fatTransacaoIR c on b.IdTransacaoIR = c.IdTransacaoIR

update tmpVendaLegadoAtiva
set IdTransacaoIR = b.IdTransacaoIR, 
IdTransacaoAdquirente = c.IdTransacaoAdquirente
from tmpVendaLegadoAtiva a
inner join dimTransacaoIR b on a.CodigoGateway = b.IDERP
left join fatTransacaoIR c on b.IdTransacaoIR = c.IdTransacaoIR
where a.IdTransacaoIR = -1
and a.CodigoGateway is not null

update tmpVendaLegadoAtiva
set IdTransacaoIR = b.IdTransacaoIR, 
IdTransacaoAdquirente = c.IdTransacaoAdquirente
from tmpVendaLegadoAtiva a
inner join dimTransacaoIR b on a.NroAutorizacaoAdquirente = b.NroAutorizacao
								and a.NSUHost = b.NSU
								and convert(date, a.DataCompra) = convert(date, b.DtTransacao) -- todas as datas desta amostragem encontram-se em branco.
								--and DATEDIFF(d, a.DataCompra, b.DtTransacao) between -5 and 5 -- Limite de diferença de 5 dias. 
								and a.ValorVendaTotal = b.ValorPagamento
left join fatTransacaoIR c on b.IdTransacaoIR = c.IdTransacaoIR
where a.IdTransacaoIR = -1
and a.NroAutorizacaoAdquirente is not null


--===================================================================================
-- LINK ENTRE VENDA E TRANSACAO ADQUIRENTE
--===================================================================================

update tmpVendaLegadoAtiva
set IdTransacaoIR = c.IdTransacaoIR, 
IdTransacaoAdquirente = b.IdTransacaoAdquirente
from tmpVendaLegadoAtiva a
inner join dimTransacaoAdquirente b on a.CodigoGateway = b.IDERP
left join fatTransacaoAdquirente c on b.IdTransacaoAdquirente = c.IdTransacaoAdquirente
where a.IdTransacaoAdquirente = -1
and a.CodigoGateway is not null


update tmpVendaLegadoAtiva
set IdTransacaoIR = c.IdTransacaoIR, 
IdTransacaoAdquirente = b.IdTransacaoAdquirente
from tmpVendaLegadoAtiva a
inner join dimTransacaoAdquirente b on a.NroAutorizacaoAdquirente = b.NroAutorizacao
								and a.NSUHost = b.NSU
								and DATEDIFF(d, convert(date, a.DataCompra), b.Data) between -5 and 5  -- Limite de diferença de 5 dias. 
								--and a.ValorVendaTotal = b.ValorBruto
left join fatTransacaoAdquirente c on b.IdTransacaoAdquirente = c.IdTransacaoAdquirente
where a.IdTransacaoAdquirente = -1
and a.NroAutorizacaoAdquirente is not null

-- Set lote de venda
update tmpVendaLegadoAtiva
set IdLoteIR = b.IdLoteVenda
from tmpVendaLegadoAtiva a
inner join fatTransacaoAdquirente b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente
where a.IdLoteIR = -1 and isnull(b.IdLoteVenda, -1) <> -1


--========================================================
-- ANALISAR AGORA O RESULTADO DA TABELA. 
-- VERIFICAR TRANSACAO VS VENDA E LOTE VENDA VS LOTE PAGTO.
--========================================================

-- ESTOU AQUI!!!

-- Montar agora select para comparar ...
-- Comparativo venda vs transação
select a.NroAutorizacaoAdquirente, b.NroAutorizacao, a.Bandeira as BandeiraVenda, b.Bandeira, 
		a.DataCompra, b.Data, a.NomeFormaPagamento, d.Produto, a.NumeroCartao, 
		b.NroCartao, a.NumeroParcelas, b.Parc, a.ValorVendaTotal, c.ValorBrutoAdquirente, 
		c.ValorBrutoIR, c.ValorCancelado, c.ValorChargeback, a.QtdeIngressos, a.PlataformaUtilizada, 
		a.IdVendaIR, a.IdTransacaoAdquirente, a.IdTransacaoIR
into #tmp
from tmpVendaLegadoAtiva a
left join dimTransacaoAdquirente b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente
left join fatTransacaoAdquirente c on b.IdTransacaoAdquirente = c.IdTransacaoAdquirente
left join dimProduto d on c.IdProduto = d.IdProduto


-- R$ 2.069.182.12 de venda sem lote (IdLoteVenda = -1)
-- Comparativo por lote
drop table #tmpLote
select a.IdLoteIR, sum(a.ValorVendaTotal) as ValorVenda, sum(b.ValorBrutoAdquirente) as ValorBrutoAdquirente, sum(b.ValorComissaoAdquirente) as ComissaoAdquirente, sum(b.ValorCanceladoLiquido) as CanceladoLiquido, sum(b.ValorChargebackLiquido) as CBKLiquido
into #tmpLote
from tmpVendaLegadoAtiva a
inner join fatTransacaoAdquirente b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente
where IdLoteIR <> -1
group by a.IdLoteIR

select a.IdLoteIR, a.ValorVenda, a.ValorBrutoAdquirente, a.ComissaoAdquirente, a.CanceladoLiquido, a.CBKLiquido, sum(d.ValorPrevisto) as ValorPrevisto, sum(d.ValorPago) as ValorPago, sum(d.ValorCancelamentoLiquido) as Cancelado, sum(d.ValorCBKLiquido) as cbk
from #tmpLote a
inner join dimLoteVenda c on a.IdLoteIR = c.IdLoteVenda
inner join fatFluxoCaixa d on c.IdLoteVenda = d.IdLoteVenda
group by a.IdLoteIR, a.ValorVenda, a.ValorBrutoAdquirente, a.ComissaoAdquirente, a.CanceladoLiquido, a.CBKLiquido
--select * from #tmp where IdTransacaoAdquirente <> -1



select * from fatTransacaoAdquirente where IdLoteVenda is null



select * from tmpVendaLegadoAtiva

-- Não associado. 
--select count(*) from tmpVendaLegadoAtiva where IdTransacaoIR = -1

-- 157.926
select count(a.IdVendaIR)
from tmpVendaLegadoAtiva a
inner join dimTransacaoAdquirente b on a.CodigoGateway = b.IDERP
where a.CodigoGateway is not null
--and a.IdTransacaoIR = -1
order by CodigoGateway, a.IdVendaIR, a.IdTransacaoIR


-- 1.080.873
-- 1.080.869
select count(*) from dimTransacaoAdquirente where IDERP is null

1.584.957
428.003
select count(*) from dimTransacaoIR where IDERP is null

select * from dimTransacaoIR where IDERP is null







