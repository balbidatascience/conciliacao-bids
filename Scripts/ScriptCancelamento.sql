use IR

USE [IR]
GO


--**********************************************************************************************************
-- Script analise cancelamentos
--**********************************************************************************************************
select * from dimstatusCancelamento
select distinct TipoCancelamento from dimCancelamento

truncate table #tmpCancelamento

-- 2) Pedidos Cancelados
select b.IdTransacaoAdquirente, 
		sum(ValorBrutoCancelado) as TotalCancelado, 
		c.VlrBruto - sum(ValorBrutoCancelado) as Saldo
into #tmpCancelamento
from fatCancelamento b
inner join dimCancelamento c on b.IdCancelamento = c.IdCancelamento
where b.IdTransacaoAdquirente <> -1
and c.TipoCancelamento = 'Cancelamento'
group by b.IdTransacaoAdquirente, c.VlrBruto

update fatTransacaoAdquirente
set IdStatusCancelamento = 2,
	ValorCancelado = b.TotalCancelado, 
	SaldoDebito = b.Saldo
from fatTransacaoAdquirente a
inner join #tmpCancelamento b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente 

truncate table #tmpCancelamento

-- 3) Chargebacks
insert into #tmpCancelamento
select	a.IdTransacaoAdquirente, 
		sum(ValorBrutoCancelado) as TotalChargeback, 
		b.VlrBruto - sum(ValorBrutoCancelado) as Saldo
from fatCancelamento a
inner join dimCancelamento b on a.IdCancelamento = b.IdCancelamento
where IdTransacaoAdquirente <> -1
and b.TipoCancelamento = 'Chargeback'
group by IdTransacaoAdquirente, VlrBruto
order by IdTransacaoAdquirente
-- Update
update fatTransacaoAdquirente
set IdStatusCancelamento = 3,
	ValorChargeback = b.TotalCancelado, 
	SaldoDebito = b.Saldo
from fatTransacaoAdquirente a
inner join #tmpCancelamento b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente 

truncate table #tmpCancelamento 

-- 4) Débito replicado
insert into #tmpCancelamento
select	a.IdTransacaoAdquirente, 
		sum(ValorBrutoCancelado) as TotalCanceladoCBK, 
		b.VlrBruto - sum(ValorBrutoCancelado) as Saldo
from fatCancelamento a
inner join dimCancelamento b on a.IdCancelamento = b.IdCancelamento
where IdTransacaoAdquirente <> -1
group by IdTransacaoAdquirente, VlrBruto
having sum(ValorBrutoCancelado) > VlrBruto and count(distinct TipoCancelamento) = 1 and COUNT(TipoCancelamento) > 1 
order by IdTransacaoAdquirente
-- Update
update fatTransacaoAdquirente
set IdStatusCancelamento = 4,
	SaldoDebito = b.Saldo
from fatTransacaoAdquirente a
inner join #tmpCancelamento b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente

truncate table #tmpCancelamento

-- 5) Cancelamento e Chargeback
insert into #tmpCancelamento
select	a.IdTransacaoAdquirente, 
		sum(ValorBrutoCancelado) as TotalCanceladoCBK, 
		b.VlrBruto - sum(ValorBrutoCancelado) as Saldo
from fatCancelamento a
inner join dimCancelamento b on a.IdCancelamento = b.IdCancelamento
where IdTransacaoAdquirente <> -1
group by IdTransacaoAdquirente, VlrBruto
having sum(ValorBrutoCancelado) > VlrBruto and count(distinct TipoCancelamento) > 1 
order by IdTransacaoAdquirente
-- Update
update fatTransacaoAdquirente
set IdStatusCancelamento = 5,
	SaldoDebito = b.Saldo
from fatTransacaoAdquirente a
inner join #tmpCancelamento b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente

truncate table #tmpCancelamento

-- 6) Debito menor
insert into #tmpCancelamento
select	a.IdTransacaoAdquirente,
		sum(ValorBrutoCancelado) as TotalCancelado, 
		b.VlrBruto - sum(ValorBrutoCancelado) as Saldo
from fatCancelamento a
inner join dimCancelamento b on a.IdCancelamento = b.IdCancelamento
where IdTransacaoAdquirente <> -1
group by IdTransacaoAdquirente, VlrBruto
having sum(ValorBrutoCancelado) < VlrBruto
order by IdTransacaoAdquirente
-- Update
update fatTransacaoAdquirente
set IdStatusCancelamento = 6,
	SaldoDebito = b.Saldo
from fatTransacaoAdquirente a
inner join #tmpCancelamento b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente

drop table #tmpCancelamento

--------------------------------------------------
-- Para update na fatTransacaoAdquirente
-- Criar dimDivergenciaCancelamento
--------------------------------------------------
select	a.IdTransacaoAdquirente, 
		b.VlrBruto, 
		sum(ValorBrutoCancelado) as TotalCancelado, 
		b.VlrBruto - sum(ValorBrutoCancelado) as Saldo, 
		count(distinct TipoCancelamento) as QtdeDebitos
from fatCancelamento a
inner join dimCancelamento b on a.IdCancelamento = b.IdCancelamento
where IdTransacaoAdquirente <> -1
group by IdTransacaoAdquirente, VlrBruto
having sum(ValorBrutoCancelado) > VlrBruto
order by IdTransacaoAdquirente
--------------------------------------------------
-- Saldo debito menor
select	a.IdTransacaoAdquirente, 
		b.VlrBruto, 
		sum(ValorBrutoCancelado) as TotalCancelado, 
		b.VlrBruto - sum(ValorBrutoCancelado) as Saldo, 
		count(distinct TipoCancelamento) as QtdeDebitos
from fatCancelamento a
inner join dimCancelamento b on a.IdCancelamento = b.IdCancelamento
where IdTransacaoAdquirente <> -1
group by IdTransacaoAdquirente, VlrBruto
having sum(ValorBrutoCancelado) < VlrBruto
order by IdTransacaoAdquirente
-----------------------------------------------------

select a.IdCancelamento, 
		ValorBruto * -1,
		-1*ValorComissao,
		-1*ValorLiquido,
		-1*ValorBrutoCancelado,
		-1*ValorLiquidoCancelado
from fatCancelamento a
inner join dimCancelamento b on a.IdCancelamento = b.IdCancelamento
where b.TipoCancelamento = 'Estorno de Chargeback' and ValorBruto >= 0

update fatCancelamento
set ValorBruto = ValorBruto * -1, 
ValorComissao = ValorComissao * -1, 
ValorLiquido = ValorLiquido * -1, 
ValorBrutoCancelado = ValorBrutoCancelado * -1,
ValorLiquidoCancelado = ValorLiquidoCancelado * -1
from fatCancelamento a
inner join dimCancelamento b on a.IdCancelamento = b.IdCancelamento
where b.TipoCancelamento = 'Estorno de Chargeback' and ValorBruto >= 0

select	IdTransacaoAdquirente, count(IdCancelamento) as QtdeCanc
from fatCancelamento
where IdTransacaoAdquirente <> -1
group by IdTransacaoAdquirente
having count(IdCancelamento) > 1
order by QtdeCanc desc

select b.TipoCancelamento, b.MotivoCancelamento, a.*
from fatCancelamento a
inner join dimCancelamento b on a.IdCancelamento = b.IdCancelamento
where a.IdTransacaoAdquirente in (
242510,
246592,
279573,
276244,
244130) order by IdTransacaoAdquirente

select * from dimTransacaoAdquirente where IdTransacaoAdquirente in (
242510,
246592,
279573,
276244,
244130)

--**********************************************************************************************************
-- Script Load dimCancelamento
--**********************************************************************************************************
--select * from dsCancelamento

-- 3520
select * from dimCancelamento

select top 250 * from dimCancelamento order by 1 desc

select * from dimCancelamento where TID in ('N0000000001864922311','62R24283XU9167213','7K107709M8064163H') order by TID


MERGE INTO dimCancelamento AS Target
USING (
		SELECT distinct [TipoCancelamento]
		  ,[NroAutorizacao]
		  ,[IDERP]
		  ,[Estabelecimento]
		  ,[CategoriaEstabelecimento]
		  ,[Adquirente]
		  ,[Bandeira]
		  ,[Tipo]
		  ,[Produto]
		  ,[Localizador]
		  ,[NroTerminal]
		  ,[LoteRO]
		  ,[LoteUnico]
		  ,[NrSequencia]
		  ,[NrReferenciaPedido]
		  ,[DtCaptura]
		  ,[DtVenda]
		  ,[DtCancelamento]
		  ,[NroCartao]
		  ,[NSU]
		  ,[TID]
		  ,[Parc]
		  ,[VlrBruto]
		  ,[VlrComissao]
		  ,[VlrLiquido]
		  ,[VlrBrutoCancelamento]
		  ,[VlrLiquidoCancelamento]
		  ,[MotivoCancelamento]
		  ,[Conciliacao]
		  ,[IDERPCanal]
		  ,[NomeCanal]
		  ,[NomeTarefa]
		  ,[SituacaoTarefa]
	  FROM [dbo].[dsCancelamento]
) AS Source ([TipoCancelamento]
		  ,[NroAutorizacao]
		  ,[IDERP]
		  ,[Estabelecimento]
		  ,[CategoriaEstabelecimento]
		  ,[Adquirente]
		  ,[Bandeira]
		  ,[Tipo]
		  ,[Produto]
		  ,[Localizador]
		  ,[NroTerminal]
		  ,[LoteRO]
		  ,[LoteUnico]
		  ,[NrSequencia]
		  ,[NrReferenciaPedido]
		  ,[DtCaptura]
		  ,[DtVenda]
		  ,[DtCancelamento]
		  ,[NroCartao]
		  ,[NSU]
		  ,[TID]
		  ,[Parc]
		  ,[VlrBruto]
		  ,[VlrComissao]
		  ,[VlrLiquido]
		  ,[VlrBrutoCancelamento]
		  ,[VlrLiquidoCancelamento]
		  ,[MotivoCancelamento]
		  ,[Conciliacao]
		  ,[IDERPCanal]
		  ,[NomeCanal]
		  ,[NomeTarefa]
		  ,[SituacaoTarefa]
			)
ON (Target.TipoCancelamento  = Source.TipoCancelamento
	and isnull(Target.NroAutorizacao,0) = isnull(Source.NroAutorizacao,0)
	and isnull(Target.IDERP, 0) = isnull(Source.IDERP, 0)
	and Target.[Estabelecimento] = Source.[Estabelecimento]
	and Target.[Adquirente] = Source.[Adquirente]
	and Target.[Bandeira] = Source.[Bandeira]
	and isnull(Target.Tipo,0) = isnull(Source.Tipo,0) 
	and isnull(Target.[NroTerminal],0) = isnull(Source.[NroTerminal],0) 
	and isnull(Target.[DtCaptura], 0) = isnull(Source.[DtCaptura],0) 
	and isnull(Target.[DtVenda],0) = isnull(Source.[DtVenda],0)
	and isnull(Target.[DtCancelamento],0) = isnull(Source.[DtCancelamento],0)
	and isnull(Target.[NroCartao],0) = isnull(Source.[NroCartao], 0)
	and isnull(Target.[NSU],0) = isnull(Source.[NSU],0)
	and isnull(Target.[TID], 0) = isnull(Source.[TID], 0)
	and Target.[Parc] = Source.[Parc]
	and Target.[VlrBruto] = Source.[VlrBruto]
	and Target.[VlrComissao] = Source.[VlrComissao]
	and Target.[MotivoCancelamento] = Source.[MotivoCancelamento]
	and Target.[VlrBruto] = Source.[VlrBruto])
WHEN NOT MATCHED BY TARGET THEN
 INSERT ([TipoCancelamento]
           ,[NroAutorizacao]
           ,[IDERP]
           ,[Estabelecimento]
           ,[CategoriaEstabelecimento]
           ,[Adquirente]
           ,[Bandeira]
           ,[Tipo]
           ,[Produto]
           ,[Localizador]
           ,[NroTerminal]
           ,[LoteRO]
           ,[LoteUnico]
           ,[NrSequencia]
           ,[NrReferenciaPedido]
           ,[DtCaptura]
           ,[DtVenda]
           ,[DtCancelamento]
           ,[NroCartao]
           ,[NSU]
           ,[TID]
           ,[Parc]
           ,[VlrBruto]
           ,[VlrComissao]
           ,[VlrLiquido]
           ,[VlrBrutoCancelamento]
           ,[VlrLiquidoCancelamento]
           ,[MotivoCancelamento]
           ,[Conciliacao]
           ,[IDERPCanal]
           ,[NomeCanal]
           ,[NomeTarefa]
           ,[SituacaoTarefa])
 VALUES (Source.[TipoCancelamento]
		  ,Source.[NroAutorizacao]
		  ,Source.[IDERP]
		  ,Source.[Estabelecimento]
		  ,Source.[CategoriaEstabelecimento]
		  ,Source.[Adquirente]
		  ,Source.[Bandeira]
		  ,Source.[Tipo]
		  ,Source.[Produto]
		  ,Source.[Localizador]
		  ,Source.[NroTerminal]
		  ,Source.[LoteRO]
		  ,Source.[LoteUnico]
		  ,Source.[NrSequencia]
		  ,Source.[NrReferenciaPedido]
		  ,Source.[DtCaptura]
		  ,Source.[DtVenda]
		  ,Source.[DtCancelamento]
		  ,Source.[NroCartao]
		  ,Source.[NSU]
		  ,Source.[TID]
		  ,Source.[Parc]
		  ,Source.[VlrBruto]
		  ,Source.[VlrComissao]
		  ,Source.[VlrLiquido]
		  ,Source.[VlrBrutoCancelamento]
		  ,Source.[VlrLiquidoCancelamento]
		  ,Source.[MotivoCancelamento]
		  ,Source.[Conciliacao]
		  ,Source.[IDERPCanal]
		  ,Source.[NomeCanal]
		  ,Source.[NomeTarefa]
		  ,Source.[SituacaoTarefa])
WHEN MATCHED THEN UPDATE 
 SET Target.[VlrLiquido] = Source.[VlrLiquido],
  Target.[VlrBrutoCancelamento] = Source.[VlrBrutoCancelamento],
  Target.[VlrLiquidoCancelamento] = Source.[VlrLiquidoCancelamento], 
  Target.[Conciliacao] = Source.[Conciliacao],
  Target.[IDERPCanal] = Source.[IDERPCanal],
  Target.[SituacaoTarefa]  = Source.[SituacaoTarefa];




--**********************************************************************************************************
-- Script Load fatCancelamento
--**********************************************************************************************************

-- 31
select * from dimCancelamento
where IdCancelamento in (
select IdCancelamento from fatCancelamento where IdTransacaoAdquirente = -1)

select a.*, '***********' as [####], c.ValorBrutoAdquirente , b.*
from dimCancelamento a
inner join dimTransacaoAdquirente b on a.TID = b.TID
inner join fatTransacaoAdquirente c on b.IdTransacaoAdquirente = c.IdTransacaoAdquirente
where IdCancelamento in (
select IdCancelamento from fatCancelamento where IdTransacaoAdquirente = -1 and IdCancelamento not in (select IdCancelamento from bkpfatCancelamento where IdTransacaoAdquirente = -1)
)


MERGE INTO fatCancelamento AS Target
USING (
		select  distinct 
			b.IdCancelamento, 
			isnull(c.IdTransacaoAdquirente, -1) as IdTransacaoAdquirente,
			isnull(d.IdTransacaoIR, -1) as IdTransacaoIR,
			isnull(d.IdSituacao, 2) as IdSituacao,
			isnull(d.IdAdquirente, -1) as IdAdquirente,
			isnull(d.IdProduto, -1) as IdProduto,
			isnull(isnull(d.IdDataCaptura, e.IdTempo), -1) as IdDataCaptura,
			isnull(isnull(d.IdDataVenda, f.IdTempo), -1) as IdDataVenda,
			isnull(g.IdTempo, -1) as IdDataCancelamento, 
			a.Parc as Parcelas, 
			a.VlrBruto as ValorBruto, 
			isnull(a.VlrComissao, 0) as ValorComissao, 
			isnull(a.VlrLiquido, 0) as ValorLiquido, 
			isnull(a.VlrBrutoCancelamento, 0) as ValorBrutoCancelado, 
			isnull(a.VlrLiquidoCancelamento, 0) as ValorLiquidoCancelado
	from dsCancelamento a
	inner join dimCancelamento b on a.TipoCancelamento  = b.TipoCancelamento
								and isnull(a.NroAutorizacao,0) = isnull(b.NroAutorizacao,0)
								and isnull(a.IDERP, 0) = isnull(b.IDERP, 0)
								and a.[Estabelecimento] = b.[Estabelecimento]
								and a.[Adquirente] = b.[Adquirente]
								and a.[Bandeira] = b.[Bandeira]
								and isnull(a.Tipo,0) = isnull(b.Tipo,0) 
								and isnull(a.[NroTerminal],0) = isnull(b.[NroTerminal],0) 
								and isnull(a.[DtCaptura], 0) = isnull(b.[DtCaptura],0) 
								and isnull(a.[DtVenda],0) = isnull(b.[DtVenda],0)
								and isnull(a.[DtCancelamento],0) = isnull(b.[DtCancelamento],0)
								and isnull(a.[NroCartao],0) = isnull(b.[NroCartao], 0)
								and isnull(a.[NSU],0) = isnull(b.[NSU],0)
								and isnull(a.[TID], 0) = isnull(b.[TID], 0)
								and a.[Parc] = b.[Parc]
								and a.[VlrBruto] = b.[VlrBruto]
								and a.[VlrComissao] = b.[VlrComissao]
								and a.[MotivoCancelamento] = b.[MotivoCancelamento]
								and a.[VlrBruto] = b.[VlrBruto]
	left join dimTransacaoAdquirente c on a.NroAutorizacao = c.NroAutorizacao
										and a.NSU = c.NSU
										and a.DtCaptura = c.DtCaptura
	left join fatTransacaoAdquirente d on c.IdTransacaoAdquirente = d.IdTransacaoAdquirente
	left join dimTempo e on convert(date, a.DtCaptura) = convert(date, e.DATA)
	left join dimTempo f on convert(date, a.DtVenda) = convert(date, f.DATA)
	left join dimTempo g on convert(date, a.DtCancelamento) = convert(date, g.DATA)
	left join fatCancelamento h on b.IdCancelamento = h.IdCancelamento

) AS Source (IdCancelamento, 
			IdTransacaoAdquirente,
			IdTransacaoIR,
			IdSituacao,
			IdAdquirente,
			IdProduto,
			IdDataCaptura,
			IdDataVenda,
			IdDataCancelamento, 
			Parcelas, 
			ValorBruto, 
			ValorComissao, 
			ValorLiquido, 
			ValorBrutoCancelado, 
			ValorLiquidoCancelado
			)
ON (Target.IdCancelamento = Source.IdCancelamento)
WHEN NOT MATCHED BY TARGET THEN
 INSERT (IdCancelamento, 
		IdTransacaoAdquirente,
		IdTransacaoIR,
		IdSituacao,
		IdAdquirente,
		IdProduto,
		IdDataCaptura,
		IdDataVenda,
		IdDataCancelamento, 
		Parcelas, 
		ValorBruto, 
		ValorComissao, 
		ValorLiquido, 
		ValorBrutoCancelado, 
		ValorLiquidoCancelado)
 VALUES (Source.IdCancelamento, 
			Source.IdTransacaoAdquirente,
			Source.IdTransacaoIR,
			Source.IdSituacao,
			Source.IdAdquirente,
			Source.IdProduto,
			Source.IdDataCaptura,
			Source.IdDataVenda,
			Source.IdDataCancelamento, 
			Source.Parcelas, 
			Source.ValorBruto, 
			Source.ValorComissao, 
			Source.ValorLiquido, 
			Source.ValorBrutoCancelado, 
			Source.ValorLiquidoCancelado)
WHEN MATCHED THEN UPDATE 
 SET Target.IdTransacaoAdquirente = Source.IdTransacaoAdquirente,
  Target.IdTransacaoIR = Source.IdTransacaoIR,
  Target.IdSituacao = Source.IdSituacao, 
  Target.IdAdquirente = Source.IdAdquirente,
  Target.IdProduto = Source.IdProduto,
  Target.IdDataCaptura = Source.IdDataCaptura,
  Target.ValorBrutoCancelado = Source.ValorBrutoCancelado,
  Target.ValorLiquidoCancelado = Source.ValorLiquidoCancelado;

-- Atualiza as exceções via (TID, NSU, Autorizacao e Valor)
update fatCancelamento 
	set IdTransacaoAdquirente = c.IdTransacaoAdquirente,
		IdTransacaoIR = d.IdTransacaoIR,
		IdSituacao = d.IdSituacao, 
		IdAdquirente = d.IdAdquirente,
		IdProduto = d.IdProduto,
		IdDataCaptura = d.IdDataCaptura
from fatCancelamento a 
inner join dimCancelamento b on a.IdCancelamento = b.IdCancelamento
inner join dimTransacaoAdquirente c on b.TID = c.TID
									and b.NSU = c.NSU
									and isnull(b.NroAutorizacao,0) = isnull(c.NroAutorizacao,0)
									and b.VlrBruto = a.ValorBruto
inner join fatTransacaoAdquirente d on c.IdTransacaoAdquirente = d.IdTransacaoAdquirente
where a.IdTransacaoAdquirente = -1








select a.*, '***********' as [####], c.ValorBrutoAdquirente , b.*
from dimCancelamento a
inner join dimTransacaoAdquirente b on a.TID = b.TID
inner join fatTransacaoAdquirente c on b.IdTransacaoAdquirente = c.IdTransacaoAdquirente
where IdCancelamento in (
select IdCancelamento from fatCancelamento where IdTransacaoAdquirente = -1 and IdCancelamento not in (select IdCancelamento from bkpfatCancelamento where IdTransacaoAdquirente = -1)
)

-- 3520
select  *
from fatCancelamento where IdTransacaoAdquirente is null or IdTransacaoAdquirente = -1

-- 3520
select * from dsCancelamento

-- 3750
select * from dimCancelamento


select  distinct 
		b.IdCancelamento, 
		c.IdTransacaoAdquirente,
		d.IdTransacaoIR,
		d.IdSituacao,
		d.IdAdquirente,
		d.IdProduto,
		d.IdDataCaptura, e.IdTempo,
		d.IdDataVenda, f.IdTempo,
		g.IdTempo as IdDataCancelamento, 
		a.Parc as Parcelas, 
		d.ValorBrutoAdquirente,
		a.VlrBruto, 
		isnull(a.VlrComissao, 0) as ValorComissao, 
		isnull(a.VlrLiquido, 0) as ValorLiquido, 
		isnull(a.VlrBrutoCancelamento, 0) as ValorBrutoCancelado, 
		isnull(a.VlrLiquidoCancelamento, 0) as ValorLiquidoCancelado
from dsCancelamento a
inner join dimCancelamento b on a.TipoCancelamento  = b.TipoCancelamento
							and isnull(a.NroAutorizacao,0) = isnull(b.NroAutorizacao,0)
							and isnull(a.IDERP, 0) = isnull(b.IDERP, 0)
							and a.[Estabelecimento] = b.[Estabelecimento]
							and a.[Adquirente] = b.[Adquirente]
							and a.[Bandeira] = b.[Bandeira]
							and isnull(a.Tipo,0) = isnull(b.Tipo,0) 
							and isnull(a.[NroTerminal],0) = isnull(b.[NroTerminal],0) 
							and isnull(a.[DtCaptura], 0) = isnull(b.[DtCaptura],0) 
							and isnull(a.[DtVenda],0) = isnull(b.[DtVenda],0)
							and isnull(a.[DtCancelamento],0) = isnull(b.[DtCancelamento],0)
							and isnull(a.[NroCartao],0) = isnull(b.[NroCartao], 0)
							and isnull(a.[NSU],0) = isnull(b.[NSU],0)
							and isnull(a.[TID], 0) = isnull(b.[TID], 0)
							and a.[Parc] = b.[Parc]
							and a.[VlrBruto] = b.[VlrBruto]
							and a.[VlrComissao] = b.[VlrComissao]
							and a.[MotivoCancelamento] = b.[MotivoCancelamento]
							and a.[VlrBruto] = b.[VlrBruto]
left join dimTransacaoAdquirente c on a.NroAutorizacao = c.NroAutorizacao
									and a.NSU = c.NSU
									and a.DtCaptura = c.DtCaptura
left join fatTransacaoAdquirente d on c.IdTransacaoAdquirente = d.IdTransacaoAdquirente
left join dimTempo e on convert(date, a.DtCaptura) = convert(date, e.DATA)
left join dimTempo f on convert(date, a.DtVenda) = convert(date, f.DATA)
left join dimTempo g on convert(date, a.DtCancelamento) = convert(date, g.DATA)
left join fatCancelamento h on b.IdCancelamento = h.IdCancelamento
where h.IdCancelamento is null 


-- Join via Autorizacao, NSU e (Data or LoteRO/LoteAdq)
update fatTransacaoAdquirente
set IdTransacaoIR = b.IdTransacaoIR, 
ValorBrutoIR = b.ValorPagamento
from fatTransacaoAdquirente c 
inner join dimTransacaoAdquirente a on c.IdTransacaoAdquirente = a.IdTransacaoAdquirente
inner join dimTransacaoIR b on a.NroAutorizacao = b.NroAutorizacao
		and a.NSU = b.NSU
		and (a.DtCaptura = b.DtTransacao)

-- Join via TID, NSU e Autorizacao
update fatTransacaoAdquirente 
set IdTransacaoIR = b.IdTransacaoIR, 
ValorBrutoIR = b.ValorPagamento
from fatTransacaoAdquirente c 
inner join dimTransacaoAdquirente a on c.IdTransacaoAdquirente = a.IdTransacaoAdquirente
inner join dimTransacaoIR b on a.NroAutorizacao = b.NroAutorizacao
		and a.NSU = b.NSU
		and a.TID = b.TID
where c.IdTransacaoIR = -1 and b.TID is not null

-- Join via NSU, Autorizacao e Lote
update fatTransacaoAdquirente 
set IdTransacaoIR = b.IdTransacaoIR, 
ValorBrutoIR = b.ValorPagamento
from fatTransacaoAdquirente c 
inner join dimTransacaoAdquirente a on c.IdTransacaoAdquirente = a.IdTransacaoAdquirente
inner join dimTransacaoIR b on a.NroAutorizacao = b.NroAutorizacao
							and a.NSU = b.NSU
							and a.LoteRO = b.LoteAdq
where c.IdTransacaoIR = -1 and b.LoteAdq is not null


-- join via Bandeira, Autorizacao, Valor, Lote e dif. datas menor que 5 dias. 
-- Seleciona via Bandeira, Autorizacao, Valor, Lote e dif. datas menor que 5 dias. 
select distinct b.IdTransacaoIR, b.ValorPagamento, c.IdTransacaoAdquirente
into #tmpFat
from fatTransacaoAdquirente c 
inner join dimTransacaoAdquirente a on c.IdTransacaoAdquirente = a.IdTransacaoAdquirente
inner join dimTransacaoIR b on a.Bandeira = b.Bandeira
							and a.NroAutorizacao = b.NroAutorizacao
							and a.ValorBruto = b.ValorPagamento
							and  a.LoteRO = b.LoteAdq
							and DATEDIFF(d, a.DtCaptura, b.DtTransacao) between -5 and 5 -- Limite de diferença de 5 dias. 
where c.IdTransacaoIR = -1 and b.Bandeira is not null and b.NroAutorizacao is not null 

-- Deleta as transações que concidiram com alguma conciliada já.
delete from #tmpFat where IdTransacaoIR in (
		select a.IdTransacaoIR from #tmpFat a
		inner join fatTransacaoAdquirente b on a.IdTransacaoIR = b.IdTransacaoIR
		)
-- Correção manual. 
delete from #tmpFat where IdTransacaoAdquirente = 366636

-- Concilia 
update fatTransacaoAdquirente
set IdTransacaoIR = b.IdTransacaoIR, 
ValorBrutoIR = b.ValorPagamento
from fatTransacaoAdquirente a
inner join #tmpFat b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente
where a.IdTransacaoIR = -1 

drop table #tmpFat


--*************************************************************
-- Rascunho
--*************************************************************

select * from fatCancelamento where IdCancelamento in ( 
3521,
3772,
3773,
3774,
3775,
3776,
3777)

select * from dimCancelamento where IdCancelamento in ( 
3997,
3996,
3900,
3898,
3995)

select * from dimCancelamento where TID in (
'7VE54466EG5200910'
)
order by TID

select * from dimTransacaoAdquirente where TID = '7VE54466EG5200910'
