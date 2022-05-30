//
//  ContentView.swift
//  Eiler
//
//  Created by Rustam Khakhuk on 24.05.2022.
//

import SwiftUI
import SwiftUICharts

var start = 0.0
var end = 2.0

struct ContentView: View {
	@State var iterationField: String = "10"
	
	@State var chartData = buildLines()
		
    var body: some View {
		VStack(spacing: 16) {
			MultiLineChart(chartData: chartData)
				.xAxisGrid(chartData: chartData)
				.yAxisGrid(chartData: chartData)
				.xAxisLabels(chartData: chartData)
				.yAxisLabels(chartData: chartData, specifier: "%.3f")
				.legends(chartData: chartData, columns: [.init(.flexible(minimum: 0, maximum: 10000), spacing: nil, alignment: .center),.init(.flexible(minimum: 0, maximum: 10000), spacing: nil, alignment: .center)])
				.headerBox(chartData: chartData)
				.padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
				.id(chartData.id)
			

			Divider()
			HStack {
				Text("Кол-во итераций:")
					.foregroundColor(.secondary)
				TextField("", text: $iterationField)
					.frame(width: 64)
				Spacer()
				Text("Максимальная невязка : \(findDelta(data: chartData))")
					.foregroundColor(.secondary)
			}
			.padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
			
		}
		.onChange(of: iterationField, perform: { val in
			var newCount = Int(iterationField) ?? 2
			if newCount <= 1 {
				newCount = 2
			}
			chartData = buildLines(iterCount: newCount)
		})
    }
}

//поиск максимальной невязки
func findDelta(data: MultiLineChartData) -> CGFloat {
	var delta = 0.0

	for i in 0..<data.dataSets.dataSets[0].dataPoints.count {
		delta = max(delta, abs(data.dataSets.dataSets[0].dataPoints[i].value - data.dataSets.dataSets[1].dataPoints[i].value))
	}
	
	return delta
}

//построение приближенного решения методом эйлера
func buildEilerSolution(countOfIterations: Int) -> LineDataSet {
	var dataSet = LineDataSet(dataPoints: [])
	
	let step = end / CGFloat(countOfIterations)
	var x = 0.0
	var y = sqrt(2)
		
	for _ in 0..<countOfIterations {
		dataSet.dataPoints.append(LineChartDataPoint(value: y))
		
		y += step * diffEq(x: x, y: y);
		x += step;
	}
	
	dataSet.style.lineColour = .init(colour: Color(nsColor: .lightGray))
	dataSet.style.strokeStyle = .init(lineWidth: 2)
	dataSet.style.lineType = .line
	dataSet.legendTitle = "Приближенное решение"

	return dataSet
}

//дифференциальное уравнение
func diffEq(x: CGFloat, y: CGFloat) -> CGFloat {
	return 2 * x * x * x * y * y * y - 2 * x * y
}

//получение точек точного решения для отображения графика
func buildPerfectSolution(step: CGFloat) -> LineDataSet {
	
	var dataSet = LineDataSet(dataPoints: [])
	
	var ind = start
	while (ind <= end) {
		dataSet.dataPoints.append(
			LineChartDataPoint(value: perfectSolution(x: ind))
		)
		ind += step
	}
	
	dataSet.style = LineStyle(lineColour: .init(colour: .mint), lineType: .line, strokeStyle: .init(lineWidth: 2), ignoreZero: false)
	
	dataSet.legendTitle = "Точное решение"
	
	return dataSet
}

//построение данных для графика
func buildLines(iterCount: Int = 10) -> MultiLineChartData {
	let multiSet = MultiLineDataSet(dataSets: [
		buildEilerSolution(countOfIterations: iterCount),
		buildPerfectSolution(step: end / CGFloat(iterCount))
	])
	
	let data = MultiLineChartData(dataSets: multiSet)
	
	data.metadata = ChartMetadata(title: "Решение диффреренциального уравнения", subtitle: "Методом эйлера", titleFont: .title, titleColour: .primary, subtitleFont: .title3, subtitleColour: .secondary)

	data.chartStyle.yAxisLabelColour = .gray
	data.chartStyle.yAxisGridStyle = .init(numberOfLines: 11, lineColour: .gray.opacity(0.2), lineWidth: 0.5, dash: [], dashPhase: 0)
	data.chartStyle.yAxisNumberOfLabels = 10
	data.chartStyle.yAxisLabelType = .numeric

	data.chartStyle.xAxisLabelsFrom = .chartData(rotation: .zero)

	data.chartStyle.xAxisLabelColour = .gray
	data.chartStyle.xAxisLabelPosition = .bottom
	
	data.chartStyle.globalAnimation = .easeOut(duration: 0.5)
	
	data.chartStyle.xAxisGridStyle = .init(numberOfLines: 11, lineColour: .gray.opacity(0.25), lineWidth: 0.5, dash: [5], dashPhase: 10)
	data.xAxisLabels = (1...10).map {v in "\(CGFloat(v) / 5.0)"}
	
	data.chartStyle.yAxisGridStyle = .init(numberOfLines: 11, lineColour: .gray.opacity(0.25), lineWidth: 0.5, dash: [5], dashPhase: 10)
	
	data.chartStyle.yAxisBorderColour = .gray
	data.chartStyle.xAxisBorderColour = .gray

	
	return data
}

//точное решение дифференциального уравнения
func perfectSolution(x: CGFloat) -> CGFloat {
	return 1.0 / sqrt(x * x + 0.5)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
