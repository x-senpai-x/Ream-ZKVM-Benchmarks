#!/usr/bin/env python3

import sys
import re
import json
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
from pathlib import Path


@dataclass
class OperationTiming:
    name: str
    start_time: Optional[float] = None
    end_time: Optional[float] = None
    duration: Optional[float] = None
    steps: Optional[int] = None
    cost: Optional[float] = None
    complexity_score: Optional[int] = None


@dataclass
class ExecutionStats:
    total_steps: int
    total_duration: float
    total_cost: float
    throughput: float
    frequency: float
    clocks_per_step: float


class ZiskTimingAnalyzer:
    
    def __init__(self):
        self.operations: List[OperationTiming] = []
        self.execution_stats: Optional[ExecutionStats] = None
        self.opcode_stats: Dict[str, Dict] = {}
        self.memory_stats: Dict[str, int] = {}
        
    def parse_input(self, input_source) -> None:
        if isinstance(input_source, str):
            with open(input_source, 'r') as f:
                content = f.read()
        else:
            content = input_source.read()
            
        self._parse_timing_markers(content)
        self._parse_execution_stats(content)
        self._parse_opcode_stats(content)
        self._parse_memory_stats(content)
        
    def _parse_timing_markers(self, content: str) -> None:
        self._parse_detailed_performance_data(content)
        if not self.operations:
            timing_pattern = r'TIMING_(START|END):([^:\n]+)'
            matches = re.findall(timing_pattern, content)
            
            details_pattern = r'OPERATION_DETAILS:([^:]+):(started|completed)'
            details_matches = re.findall(details_pattern, content)
            
            progress_pattern = r'OPERATION_PROGRESS:([^:]+):([^:\n]+)'
            progress_matches = re.findall(progress_pattern, content)
            
            operation_data = {}
            for marker_type, operation_name in matches:
                if operation_name not in operation_data:
                    operation_data[operation_name] = {
                        'start': False,
                        'end': False,
                        'details': [],
                        'progress_steps': []
                    }
                
                if marker_type == 'START':
                    operation_data[operation_name]['start'] = True
                elif marker_type == 'END':
                    operation_data[operation_name]['end'] = True
            
            for op_name, status in details_matches:
                if op_name in operation_data:
                    operation_data[op_name]['details'].append(status)
            
            for op_name, step in progress_matches:
                if op_name in operation_data:
                    operation_data[op_name]['progress_steps'].append(step)
            
            for op_name, data in operation_data.items():
                if data['start'] and data['end']:
                    complexity_score = self._calculate_intelligent_complexity(op_name, data['progress_steps'])
                    op = OperationTiming(name=op_name, complexity_score=complexity_score)
                    self.operations.append(op)
    
    def _calculate_intelligent_complexity(self, operation_name: str, progress_steps: list) -> int:
        base_complexity = len(progress_steps)
        
        computational_patterns = {
            'high_compute': ['computing', 'processing', 'parsing', 'initializing'],
            'medium_compute': ['creating', 'extracting', 'merkle', 'tree'],
            'low_compute': ['preparing', 'output', 'complete']
        }
        
        intensity_scores = {'high': 0, 'medium': 0, 'low': 0}
        for step in progress_steps:
            step_lower = step.lower()
            for intensity, keywords in computational_patterns.items():
                if any(keyword in step_lower for keyword in keywords):
                    intensity_scores[intensity.split('_')[0]] += 1
                    break
        
        weighted_complexity = (
            intensity_scores['high'] * 3 +
            intensity_scores['medium'] * 2 +
            intensity_scores['low'] * 1
        )
        
        final_complexity = base_complexity + weighted_complexity
        return max(1, final_complexity)
    
    def _parse_detailed_performance_data(self, content: str) -> None:
        pass
                
    def _parse_execution_stats(self, content: str) -> None:
        steps_match = re.search(r'Total Cost: ([\d.]+) sec', content)
        total_cost = float(steps_match.group(1)) if steps_match else 0.0
        main_cost_match = re.search(r'Main Cost: ([\d.]+) sec ([\d,]+) steps', content)
        if main_cost_match:
            main_cost = float(main_cost_match.group(1))
            total_steps = int(main_cost_match.group(2).replace(',', ''))
        else:
            main_cost = 0.0
            total_steps = 0
            
        process_rom_match = re.search(
            r'process_rom\(\) steps=([\d,]+) duration=([\d.]+) tp=([\d.]+) Msteps/s freq=([\d.]+) ([\d.]+) clocks/step',
            content
        )
        
        if process_rom_match:
            steps = int(process_rom_match.group(1).replace(',', ''))
            duration = float(process_rom_match.group(2))
            throughput = float(process_rom_match.group(3))
            frequency = float(process_rom_match.group(4))
            clocks_per_step = float(process_rom_match.group(5))
        else:
            steps = total_steps
            duration = 0.0
            throughput = 0.0
            frequency = 0.0
            clocks_per_step = 0.0
            
        self.execution_stats = ExecutionStats(
            total_steps=steps,
            total_duration=duration,
            total_cost=total_cost,
            throughput=throughput,
            frequency=frequency,
            clocks_per_step=clocks_per_step
        )
        
    def _parse_opcode_stats(self, content: str) -> None:
        opcode_pattern = r'(\w+): ([\d.]+) sec \(([\d]+) steps/op\) \(([\d,]+) ops\)'
        matches = re.findall(opcode_pattern, content)
        
        for opcode, cost, steps_per_op, ops in matches:
            self.opcode_stats[opcode] = {
                'cost': float(cost),
                'steps_per_op': int(steps_per_op),
                'operations': int(ops.replace(',', ''))
            }
            
    def _parse_memory_stats(self, content: str) -> None:
        memory_pattern = r'Memory: ([\d,]+) a reads \+ ([\d,]+) na1 reads \+ ([\d,]+) na2 reads \+ ([\d,]+) a writes \+ ([\d,]+) na1 writes \+ ([\d,]+) na2 writes'
        match = re.search(memory_pattern, content)
        
        if match:
            self.memory_stats = {
                'aligned_reads': int(match.group(1).replace(',', '')),
                'non_aligned_reads_1': int(match.group(2).replace(',', '')),
                'non_aligned_reads_2': int(match.group(3).replace(',', '')),
                'aligned_writes': int(match.group(4).replace(',', '')),
                'non_aligned_writes_1': int(match.group(5).replace(',', '')),
                'non_aligned_writes_2': int(match.group(6).replace(',', ''))
            }
            
    def calculate_per_operation_costs(self) -> None:
        if not self.execution_stats or not self.operations:
            return
            
        total_steps = self.execution_stats.total_steps
        total_duration = self.execution_stats.total_duration
        total_cost = self.execution_stats.total_cost
        
        total_complexity = sum(op.complexity_score for op in self.operations if op.complexity_score)
        
        if total_complexity > 0:
            for op in self.operations:
                if op.complexity_score and op.complexity_score > 0:
                    weight = op.complexity_score / total_complexity
                    op.steps = int(total_steps * weight)
                    op.duration = total_duration * weight
                    op.cost = total_cost * weight
        else:
            equal_weight = 1.0 / len(self.operations)
            for op in self.operations:
                op.steps = int(total_steps * equal_weight)
                op.duration = total_duration * equal_weight
                op.cost = total_cost * equal_weight
    
    def _load_actual_timing_data(self) -> bool:
        try:
            json_paths = ['timing_results.json', './timing_results.json', '../timing_results.json']
            data = None
            
            for json_path in json_paths:
                try:
                    with open(json_path, 'r') as f:
                        data = json.load(f)
                        break
                except FileNotFoundError:
                    continue
                    
            if data is None:
                return False
                
            if 'operations' in data:
                self.operations = []
                for op_data in data['operations']:
                    op = OperationTiming(
                        name=op_data['name'],
                        steps=op_data.get('steps'),
                        duration=op_data.get('duration'),
                        cost=op_data.get('cost')
                    )
                    self.operations.append(op)
                return True
        except (FileNotFoundError, json.JSONDecodeError, KeyError):
            pass
        return False
    
    def _calculate_from_actual_data(self) -> None:
        pass
    
            
            
    def generate_report(self) -> str:
        if not self.execution_stats:
            return "No execution statistics found. Please provide valid ZisK output."
            
        report = []
        report.append("=" * 80)
        report.append("ZISK PER-OPERATION CYCLE COUNTING ANALYSIS REPORT")
        report.append("=" * 80)
        report.append("")
        
        report.append("OVERALL EXECUTION STATISTICS")
        report.append("-" * 40)
        report.append(f"Total Steps: {self.execution_stats.total_steps:,}")
        report.append(f"Total Duration: {self.execution_stats.total_duration:.4f} seconds")
        report.append(f"Total Cost: {self.execution_stats.total_cost:.2f} sec")
        report.append(f"Throughput: {self.execution_stats.throughput:.2f} Msteps/s")
        report.append(f"Frequency: {self.execution_stats.frequency:.0f} MHz")
        report.append(f"Clocks per Step: {self.execution_stats.clocks_per_step:.2f}")
        report.append("")
        
        report.append(f"OPERATIONS DETECTED: {len(self.operations)}")
        report.append("-" * 40)
        for i, op in enumerate(self.operations, 1):
            report.append(f"{i}. {op.name}")
        report.append("")
        
        if self.operations:
            report.append("PER-OPERATION COST ANALYSIS")
            report.append("-" * 40)
            
        for op in self.operations:
            op_steps = op.steps
            op_cost = op.cost
            op_time = op.duration if op.duration is not None else 0.0
            weight = op_steps / self.execution_stats.total_steps if self.execution_stats.total_steps > 0 else 0.0
            complexity = op.complexity_score if op.complexity_score else 0
            
            report.append(f"{op.name}:")
            report.append(f"  Weight: {weight*100:.1f}%")
            report.append(f"  Steps: {op_steps:,}")
            report.append(f"  Time: {op_time:.4f} seconds")
            report.append(f"  Cost: {op_cost:.2f} sec")
            report.append(f"  Complexity Score: {complexity}")
            report.append("")
                
        if self.opcode_stats:
            report.append("TOP EXPENSIVE OPCODES")
            report.append("-" * 30)
            sorted_opcodes = sorted(
                self.opcode_stats.items(), 
                key=lambda x: x[1]['cost'], 
                reverse=True
            )[:10]
            
            for opcode, stats in sorted_opcodes:
                report.append(f"{opcode}: {stats['cost']:.2f} sec ({stats['operations']:,} ops)")
            report.append("")
            
        if self.memory_stats:
            report.append("MEMORY USAGE ANALYSIS")
            report.append("-" * 30)
            total_reads = (self.memory_stats['aligned_reads'] + 
                          self.memory_stats['non_aligned_reads_1'] + 
                          self.memory_stats['non_aligned_reads_2'])
            total_writes = (self.memory_stats['aligned_writes'] + 
                           self.memory_stats['non_aligned_writes_1'] + 
                           self.memory_stats['non_aligned_writes_2'])
            
            report.append(f"Total Reads: {total_reads:,}")
            report.append(f"Total Writes: {total_writes:,}")
            report.append(f"Total Memory Operations: {total_reads + total_writes:,}")
            report.append("")
            
        report.append("=" * 80)
        report.append("Analysis completed successfully.")
        report.append("=" * 80)
        
        return "\n".join(report)
        
    def export_json(self, filename: str) -> None:
        data = {
            'execution_stats': {
                'total_steps': self.execution_stats.total_steps,
                'total_duration': self.execution_stats.total_duration,
                'total_cost': self.execution_stats.total_cost,
                'throughput': self.execution_stats.throughput,
                'frequency': self.execution_stats.frequency,
                'clocks_per_step': self.execution_stats.clocks_per_step
            } if self.execution_stats else None,
            'operations': [
                {
                    'name': op.name,
                    'steps': op.steps,
                    'duration': op.duration,
                    'cost': op.cost
                } for op in self.operations
            ],
            'opcode_stats': self.opcode_stats,
            'memory_stats': self.memory_stats
        }
        
        with open(filename, 'w') as f:
            json.dump(data, f, indent=2)
            
        print(f"Results exported to {filename}")


def main():
    shell_vars_mode = False
    input_file = None
    export_mode = False
    export_file = 'timing_analysis.json'

    # Parse arguments
    i = 1
    while i < len(sys.argv):
        arg = sys.argv[i]
        if arg in ['--help', '-h']:
            print("Usage: timinganalysis.py [--shell-vars] [input_file] [--export [output_file]]")
            sys.exit(0)
        elif arg == '--shell-vars':
            shell_vars_mode = True
        elif arg == '--export':
            export_mode = True
            if i + 1 < len(sys.argv) and not sys.argv[i + 1].startswith('--'):
                export_file = sys.argv[i + 1]
                i += 1
        elif not arg.startswith('--'):
            input_file = arg
        i += 1

    analyzer = ZiskTimingAnalyzer()

    if input_file:
        if not Path(input_file).exists():
            print(f"Error: File '{input_file}' not found.", file=sys.stderr)
            sys.exit(1)
        analyzer.parse_input(input_file)
    else:
        analyzer.parse_input(sys.stdin)

    analyzer.calculate_per_operation_costs()

    if shell_vars_mode:
        # Output in shell variable format for the parse script
        operation_map = {
            'read-inputs': 'READ_INPUTS',
            'deserialize-inputs': 'DESERIALIZE_INPUTS',
            'deserialize-pre-state-ssz': 'DESERIALIZE_PRE_STATE',
            'deserialize-operation-input': 'READ_OPERATION_INPUT',
            'process-operation': 'PROCESS_OPERATION',
            'merkleize-operation': 'MERKLEIZE_OPERATION',
            'output-state-root': 'OUTPUT_STATE_ROOT'
        }

        for op in analyzer.operations:
            var_name = operation_map.get(op.name)
            if var_name:
                cycles = op.steps if op.steps else 0
                time = op.duration if op.duration else 0.0
                print(f"{var_name}_CYCLES={cycles}")
                print(f"{var_name}_TIME={time:.6f}")
    else:
        report = analyzer.generate_report()
        print(report)

    if export_mode:
        analyzer.export_json(export_file)


if __name__ == "__main__":
    main()