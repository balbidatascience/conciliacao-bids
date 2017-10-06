
-- Insere as distintas AK (para não replicar transacoes)

insert into dimTransacaoIR 
(NroAutorizacao, NSU, DtTransacao)
select distinct a.NroAutorizacao, a.NSU, a.DtTransacao 
from dsTransacaoIR a
left join dimTransacaoIR b on a.NroAutorizacao = b.NroAutorizacao
							and a.NSU = b.NSU
							and a.DtTransacao = b.DtTransacao
where a.NroAutorizacao is not null 
and a.NSU is not null and a.DtTransacao is not null
and b.IdTransacaoIR is null
union 
select distinct isnull(a.[NroAutorizacao], b.[NroAutorizacao]) as NroAutorizacao 
		,isnull(a.[NSU], b.[NSU]) as NSU
		,a.[DtTransacao]
from dsTransacaoIR a
inner join dimTransacaoAdquirente b on a.TID = b.TID
								and a.NroAutorizacao = b.NroAutorizacao
left join dimTransacaoIR c on isnull(a.[NroAutorizacao], b.[NroAutorizacao]) = c.NroAutorizacao
							and isnull(a.[NSU], b.[NSU]) = c.NSU
							and a.DtTransacao = c.DtTransacao
where a.NroAutorizacao is null or a.NSU is null
and c.IdTransacaoIR is null
union
-- Casos excepcionais da REDE
select distinct isnull(a.[NroAutorizacao], b.[NroAutorizacao]) as NroAutorizacao 
		,isnull(a.[NSU], b.[NSU]) as NSU
		,a.[DtTransacao]
from dsTransacaoIR a
inner join dimTransacaoAdquirente b on a.NroAutorizacao = b.NroAutorizacao
									and a.Bandeira = b.Bandeira
									and a.VlrPagamento = b.ValorBruto
									and a.Adquirente = b.Adquirente
left join dimTransacaoIR c on isnull(a.[NroAutorizacao], b.[NroAutorizacao]) = c.NroAutorizacao
							and isnull(a.[NSU], b.[NSU]) = c.NSU
							and a.DtTransacao = c.DtTransacao
where a.NroAutorizacao is null or a.NSU is null
and c.IdTransacaoIR is null
and a.Adquirente = 'REDE'

-- Realiza update nos campos criados (popula os campos que alteram com o tempo). 

CREATE TABLE #tmpTransacaoIR(
	[NroAutorizacao] [varchar](50) NULL,
	[IDERP] [varchar](50) NULL,
	[Cliente] [varchar](100) NULL,
	[Estabelecimento] [varchar](50) NULL,
	[CategoriaEstabelecimento] [varchar](50) NULL,
	[Adquirente] [varchar](50) NULL,
	--[idPagamento] [varchar](50) NULL,
	[EstabERP] [varchar](50) NULL,
	[CanalVenda] [varchar](50) NULL,
	[NroCanal] [varchar](50) NULL,
	[FormaPagto] [varchar](50) NULL,
	[DtTransacao] [datetime] NULL,
	[DtVenda] [datetime] NULL,
	[LoteInterno] [varchar](50) NULL,
	[LoteAdq] [varchar](50) NULL,
	[IDContabilPagamento] [varchar](50) NULL,
	[IDContabilVenda] [varchar](50) NULL,
	[Bandeira] [varchar](50) NULL,
	[NumCartaoCredito] [varchar](50) NULL,
	[NSU] [varchar](50) NULL,
	[TID] [varchar](50) NULL,
	[Localizador] [varchar](50) NULL,
	--[MeioDeCaptura] [varchar](50) NULL,
	[Parc] [int] NULL,
	--[QtdPagamentos] [int] NULL,
	[VlrPagamento] [decimal](9, 2) NULL,
	[VlrLiquido] [decimal](9, 2) NULL,
	[VlrParcela] [decimal](9, 2) NULL,
	[VlrAdic1] [decimal](9, 2) NULL,
	[VlrAdic2] [decimal](9, 2) NULL,
	[VlrDiferenca] [decimal](9, 2) NULL,
	[Resultado] [varchar](50) NULL,
	[Conciliacao] [varchar](50) NULL,
	[NomeTarefa] [varchar](50) NULL,
	[SituacaoTarefa] [varchar](50) NULL,
	[SituacaoParam] [varchar](10) NULL,
	--[SituacaoConcParam] [varchar](10) NULL,
	--[FormaPagParam] [varchar](10) NULL,
	[DtRegistro] [datetime] NULL
)


insert into #tmpTransacaoIR
select distinct a.[NroAutorizacao]
      ,a.[IDERP]
      ,a.[Cliente]
      ,a.[Estabelecimento]
      ,a.[CategoriaEstabelecimento]
      ,a.[Adquirente]
      ,a.[EstabERP]
      ,a.[CanalVenda]
      ,a.[NroCanal]
      ,a.[FormaPagto]
      ,a.[DtTransacao]
      ,a.[DtVenda]
      ,a.[LoteInterno]
      ,a.[LoteAdq]
      ,a.[IDContabilPagamento]
      ,a.[IDContabilVenda]
      ,a.[Bandeira]
      ,a.[NumCartaoCredito]
      ,a.[NSU]
      ,a.[TID]
      ,a.[Localizador]
      ,a.[Parc]
      ,a.[VlrPagamento]
      ,a.[VlrLiquido]
      ,a.[VlrParcela]
      ,a.[VlrAdic1]
      ,a.[VlrAdic2]
      ,a.[VlrDiferenca]
      ,a.[Resultado]
      ,a.[Conciliacao]
      ,a.[NomeTarefa]
      ,a.[SituacaoTarefa]
      ,a.[SituacaoParam]
      ,a.[DtRegistro]
from dsTransacaoIR a
inner join dimTransacaoIR b on a.NroAutorizacao = b.NroAutorizacao
							and a.NSU = b.NSU
							and a.DtTransacao = b.DtTransacao
where a.NroAutorizacao is not null 
and a.NSU is not null and a.DtTransacao is not null
union 
select distinct 
		isnull(a.[NroAutorizacao], b.[NroAutorizacao]) as NroAutorizacao 
      ,a.[IDERP]
      ,a.[Cliente]
      ,a.[Estabelecimento]
      ,a.[CategoriaEstabelecimento]
      ,a.[Adquirente]
      ,a.[EstabERP]
      ,a.[CanalVenda]
      ,a.[NroCanal]
      ,a.[FormaPagto]
      ,a.[DtTransacao]
      ,a.[DtVenda]
      ,a.[LoteInterno]
      ,a.[LoteAdq]
      ,a.[IDContabilPagamento]
      ,a.[IDContabilVenda]
      ,a.[Bandeira]
      ,a.[NumCartaoCredito]
      ,isnull(a.[NSU], b.[NSU]) as NSU
      ,a.[TID]
      ,a.[Localizador]
      ,a.[Parc]
      ,a.[VlrPagamento]
      ,a.[VlrLiquido]
      ,a.[VlrParcela]
      ,a.[VlrAdic1]
      ,a.[VlrAdic2]
      ,a.[VlrDiferenca]
      ,a.[Resultado]
      ,a.[Conciliacao]
      ,a.[NomeTarefa]
      ,a.[SituacaoTarefa]
      ,a.[SituacaoParam]
	  ,a.[DtRegistro]
from dsTransacaoIR a
inner join dimTransacaoAdquirente b on a.TID = b.TID
								and a.NroAutorizacao = b.NroAutorizacao
inner join dimTransacaoIR c on isnull(a.[NroAutorizacao], b.[NroAutorizacao]) = c.NroAutorizacao
							and isnull(a.[NSU], b.[NSU]) = c.NSU
							and a.DtTransacao = c.DtTransacao
where a.NroAutorizacao is null or a.NSU is null
and b.TID is not null
union
select distinct 
		isnull(a.[NroAutorizacao], b.[NroAutorizacao]) as NroAutorizacao 
      ,a.[IDERP]
      ,a.[Cliente]
      ,a.[Estabelecimento]
      ,a.[CategoriaEstabelecimento]
      ,a.[Adquirente]
      ,a.[EstabERP]
      ,a.[CanalVenda]
      ,a.[NroCanal]
      ,a.[FormaPagto]
      ,a.[DtTransacao]
      ,a.[DtVenda]
      ,a.[LoteInterno]
      ,a.[LoteAdq]
      ,a.[IDContabilPagamento]
      ,a.[IDContabilVenda]
      ,a.[Bandeira]
      ,a.[NumCartaoCredito]
      ,isnull(a.[NSU], b.[NSU]) as NSU
      ,a.[TID]
      ,a.[Localizador]
      ,a.[Parc]
      ,a.[VlrPagamento]
      ,a.[VlrLiquido]
      ,a.[VlrParcela]
      ,a.[VlrAdic1]
      ,a.[VlrAdic2]
      ,a.[VlrDiferenca]
      ,a.[Resultado]
      ,a.[Conciliacao]
      ,a.[NomeTarefa]
      ,a.[SituacaoTarefa]
      ,a.[SituacaoParam]
	  ,a.[DtRegistro]
from dsTransacaoIR a
inner join dimTransacaoAdquirente b on a.NroAutorizacao = b.NroAutorizacao
									and a.Bandeira = b.Bandeira
									and a.VlrPagamento = b.ValorBruto
									and a.Adquirente = b.Adquirente
inner join dimTransacaoIR c on isnull(a.[NroAutorizacao], b.[NroAutorizacao]) = c.NroAutorizacao
							and isnull(a.[NSU], b.[NSU]) = c.NSU
							and a.DtTransacao = c.DtTransacao
where a.NroAutorizacao is null or a.NSU is null
and a.Adquirente = 'REDE'

-- Update nas transações com status Conciliacao = null ou Em Aberto
UPDATE [dbo].[dimTransacaoIR]
   SET [IDERP] = b.IDERP
      ,[Cliente] = b.Cliente
      ,[Estabelecimento] = b.Estabelecimento
      ,[CategoriaEstabelecimento] = b.CategoriaEstabelecimento
      ,[Adquirente] = b.Adquirente
      ,[EstabERP] = b.EstabERP
      ,[CanalVenda] = b.CanalVenda
      ,[NroCanal] = b.NroCanal
      ,[FormaPagto] = b.FormaPagto
      ,[DtVenda] = b.DtVenda
      ,[LoteInterno] = b.LoteInterno
      ,[LoteAdq] = b.LoteAdq
      ,[IDContabilPagamento] = b.IDContabilPagamento
      ,[IDContabilVenda] = b.IDContabilVenda
      ,[Bandeira] = b.Bandeira
      ,[NumCartaoCredito] = b.NumCartaoCredito
      ,[TID] = b.TID
      ,[Localizador] = b.Localizador
      ,[Parc] = b.Parc
      ,[Resultado] = b.Resultado
      ,[Conciliacao] = b.Conciliacao
      ,[NomeTarefa] = b.NomeTarefa
      ,[SituacaoTarefa] = b.SituacaoTarefa
      ,[SituacaoParam] = b.SituacaoParam
	  ,[ValorPagamento] = b.VlrPagamento
	  ,[ValorLiquido] = b.VlrLiquido
	  ,VlrAdic1 = b.VlrAdic1
	  ,VlrAdic2 = b.VlrAdic2
	  ,VlrDiferenca = b.VlrDiferenca
from [dimTransacaoIR] a
inner join #tmpTransacaoIR b on a.NroAutorizacao = b.NroAutorizacao
							and a.NSU = b.NSU
							and a.DtTransacao = b.DtTransacao
where b.Conciliacao is null or b.Conciliacao = 'Em Aberto'

-- Update nas transações com status Conciliacao = Conciliada
UPDATE [dbo].[dimTransacaoIR]
   SET [IDERP] = b.IDERP
      ,[Cliente] = b.Cliente
      ,[Estabelecimento] = b.Estabelecimento
      ,[CategoriaEstabelecimento] = b.CategoriaEstabelecimento
      ,[Adquirente] = b.Adquirente
      ,[EstabERP] = b.EstabERP
      ,[CanalVenda] = b.CanalVenda
      ,[NroCanal] = b.NroCanal
      ,[FormaPagto] = b.FormaPagto
      ,[DtVenda] = b.DtVenda
      ,[LoteInterno] = b.LoteInterno
      ,[LoteAdq] = b.LoteAdq
      ,[IDContabilPagamento] = b.IDContabilPagamento
      ,[IDContabilVenda] = b.IDContabilVenda
      ,[Bandeira] = b.Bandeira
      ,[NumCartaoCredito] = b.NumCartaoCredito
      ,[TID] = b.TID
      ,[Localizador] = b.Localizador
      ,[Parc] = b.Parc
      ,[Resultado] = b.Resultado
      ,[Conciliacao] = b.Conciliacao
      ,[NomeTarefa] = b.NomeTarefa
      ,[SituacaoTarefa] = b.SituacaoTarefa
      ,[SituacaoParam] = b.SituacaoParam
	  ,[ValorPagamento] = b.VlrPagamento
	  ,[ValorLiquido] = b.VlrLiquido
	  ,VlrAdic1 = b.VlrAdic1
	  ,VlrAdic2 = b.VlrAdic2
	  ,VlrDiferenca = b.VlrDiferenca
from [dimTransacaoIR] a
inner join #tmpTransacaoIR b on a.NroAutorizacao = b.NroAutorizacao
							and a.NSU = b.NSU
							and a.DtTransacao = b.DtTransacao
where b.Conciliacao = 'Conciliada'

drop table #tmpTransacaoIR