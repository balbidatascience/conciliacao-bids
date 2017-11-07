-- Limpa toda a carga de fluxo de caixa
delete from fatFluxoCaixa
delete from dimLoteVenda where IdLoteVenda >=0
truncate table dsFluxoCaixa
delete from dimDomicilioBancario where IdDomicilioBancario >= 0 
update fatTransacaoAdquirente set IdLoteVenda = null


-- separa as linhas distintas.
SELECT distinct [DataVencimento]
      ,[Estabelecimento]
      ,[CategoriaEstabelecimento]
      ,[DataLoteVenda]
      ,[MesAno]
      ,[Adquirente]
      ,[FiliacaoEstabelec]
      ,[Bandeira]
      ,[TipoVenda]
      ,[Produto]
      ,[Lote]
      ,[LoteUnico]
      ,[Parcela]
      ,[QtdeParcelas]
      ,[Banco]
      ,[Agencia]
      ,[Conta]
      ,[ValorBruto]
      ,[ValorComissao]
      ,[VendasAntecCedidas]
      ,[Cancelamentos]
      ,[Chargeback]
      ,[OutrosAjustes]
      ,[ValorAntecipacoes]
      ,[DescontosAntecCessoes]
      ,[ValorPrevisto]
      ,[ValorPago]
      ,[Saldo]
      ,[VendasCedidas]
      ,[CessoesAvulsas]
      ,[DescontosCessoesAvulsas]
	into #tmp
  FROM [dbo].[dsFluxoCaixa]
GO

-- Load para a fato
INSERT INTO [dbo].[fatFluxoCaixa]
           ([IdLoteVenda]
           ,[IdDomicilioBancario]
           ,[IdProduto]
           ,[LoteUnico]
           ,[IdDataLoteVenda]
           ,[IdDataVencimento]
           ,[Parcela]
           ,[QtdeParcelas]
           ,[ValorBruto]
           ,[ValorComissao]
           ,[ValorAntecipacaoCedida]
           ,[ValorCancelamentoLiquido]
           ,[ValorCBKLiquido]
           ,[ValorOutrosAjustes]
           ,[ValorAntecipacao]
           ,[TaxaAntecipacao]
           ,[ValorPrevisto]
           ,[ValorPago]
           ,[Saldo])
select b.IdLoteVenda, 
		c.IdConta, 
		isnull(d.IdProduto, '-1') as IdProduto, 
		a.LoteUnico, 
		isnull(e.IdTempo, '-1') as IdDataLoteVenda, 
		isnull(f.IdTempo, '-1') as IdDataVencimento, 
		isnull(a.Parcela, 0) as Parcela, 
		a.QtdeParcelas, 
		isnull(a.ValorBruto, 0) as ValorBruto, 
		isnull(a.ValorComissao, 0) as ValorComissao, 
		isnull(a.VendasAntecCedidas, 0) as ValorAntecipacaoCedida, 
		isnull(a.Cancelamentos, 0) as ValorCancelamentoLiquido, 
		isnull(a.Chargeback, 0) as ValorCahrgebackLiquido, 
		isnull(a.OutrosAjustes, 0) as ValorOutrosAjustes, 
		isnull(a.ValorAntecipacoes, 0) as ValorAntecipacao, 
		isnull(a.DescontosAntecCessoes, 0) as TaxaAntecipacao, 
		isnull(a.ValorPrevisto, 0) as ValorPrevisto, 
		isnull(a.ValorPago, 0) as ValorPago, 
		isnull(a.Saldo, 0) as Saldo 
from #tmp a
left join dimLoteVenda b on isnull(a.Lote, '-1') = b.Lote
						and isnull(a.LoteUnico, '-1') = b.LoteUnico
						and isnull(a.FiliacaoEstabelec, '-1') = b.FiliacaoEstabelecimento
						and a.Adquirente = b.Adquirente
						and a.Estabelecimento = b.Estabelecimento
left join dimDomicilioBancario c on isnull(a.Banco, 0) = c.Banco
								and isnull(a.Agencia, 0) = c.Agencia
								and isnull(a.Conta, 0) = c.Conta
left join dimProduto d on a.TipoVenda = d.Tipo
						and a.Produto = d.Produto
						and a.Bandeira = d.Bandeira
left join dimTempo e on a.DataLoteVenda = e.DATA
left join dimTempo f on a.DataVencimento = f.DATA
left join fatFluxoCaixa g on a.LoteUnico = g.LoteUnico
							and a.Lote = b.Lote
							and isnull(a.Parcela, 0) = g.Parcela
							and isnull(a.ValorBruto, 0) = g.ValorBruto
							and isnull(a.VendasAntecCedidas, 0) = g.ValorAntecipacaoCedida
							and isnull(a.ValorPago, 0) = g.ValorPago
							and isnull(a.[Cancelamentos], 0) = g.ValorCancelamentoLiquido
							and e.IdTempo = g.IdDataLoteVenda
							and f.IdTempo = g.IdDataVencimento
where g.IdLoteVenda is null -- Somente registros novos

drop table #tmp
