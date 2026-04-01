"""
DCCS Task Flow Diagram Generator
Generates a publication-ready flowchart for the DCCS (Dimensional Change Card Sort) task workflow.

Usage:
    python generate_dccs_flow_diagram.py

Output:
    - dccs_flow_diagram.png (high-resolution PNG)
    - dccs_flow_diagram.pdf (vector PDF for publications)
    - dccs_flow_diagram.svg (scalable vector graphics)
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, ConnectionPatch
import numpy as np

def create_dccs_flow_diagram(output_format='png', dpi=300, figsize=(8, 12)):
    """
    Create DCCS Task Flow Diagram
    
    Parameters:
    -----------
    output_format : str
        Output format: 'png', 'pdf', 'svg', or 'all'
    dpi : int
        Resolution for raster formats (default: 300 for publication quality)
    figsize : tuple
        Figure size in inches (width, height)
    """
    
    # Create figure with high DPI for publication quality
    fig, ax = plt.subplots(figsize=figsize, dpi=dpi)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 16)
    ax.axis('off')
    
    # Define node positions (vertical flow)
    y_positions = np.linspace(15, 1, 9)  # 9 nodes from top to bottom
    x_center = 5
    
    # Define node properties
    nodes = [
        {
            'label': 'START\nChild begins assessment\nAge verification (5.5-6.9 years)',
            'color': '#4CAF50',  # Green
            'text_color': 'white',
            'shape': 'ellipse'
        },
        {
            'label': 'PRE-SWITCH INSTRUCTION\nDisplay sorting rule (Rule A)\n"Sort by Color"\nShow example trials\nConfirm understanding',
            'color': '#2196F3',  # Blue
            'text_color': 'white',
            'shape': 'rectangle'
        },
        {
            'label': 'PRE-SWITCH BLOCK\n(Rule A Execution)\nPresent stimulus\nChild selects left/right\nRecord: Trial #, Stimulus,\nResponse, RT (ms), Correct/Incorrect\nRepeat 15-20 trials',
            'color': '#2196F3',  # Blue
            'text_color': 'white',
            'shape': 'rectangle'
        },
        {
            'label': 'RULE SWITCH INSTRUCTION\nDisplay new rule (Rule B)\n"Now sort by Shape"\nExplicit verbal + visual instruction\nReset trial counter\nMark phase as "Post-Switch"',
            'color': '#FF9800',  # Orange
            'text_color': 'white',
            'shape': 'rectangle'
        },
        {
            'label': 'POST-SWITCH BLOCK\n(Rule B Execution)\nPresent same stimuli\nRecord: Trial #, RT, Correct/Incorrect\nIs Post-Switch = True\nPerseverative Error flag\nRepeat 15-20 trials',
            'color': '#F44336',  # Red
            'text_color': 'white',
            'shape': 'rectangle'
        },
        {
            'label': 'FEATURE COMPUTATION\nPre-switch accuracy\nPost-switch accuracy\nSwitch cost (RTpost - RTpre)\nPerseverative error rate\nAccuracy drop %\nRT variability',
            'color': '#9C27B0',  # Purple
            'text_color': 'white',
            'shape': 'rectangle'
        },
        {
            'label': 'AGE NORMALIZATION\nApply z-score:\nz = (x - μ_age) / σ_age',
            'color': '#00BCD4',  # Cyan
            'text_color': 'white',
            'shape': 'rectangle'
        },
        {
            'label': 'ML FEATURE EXPORT\nStore features in session\nSend to Logistic Regression model\nGenerate risk probability',
            'color': '#795548',  # Brown
            'text_color': 'white',
            'shape': 'rectangle'
        },
        {
            'label': 'END\nReturn risk score\nto clinician dashboard',
            'color': '#4CAF50',  # Green
            'text_color': 'white',
            'shape': 'ellipse'
        }
    ]
    
    # Draw nodes
    node_boxes = []
    for i, (y_pos, node) in enumerate(zip(y_positions, nodes)):
        # Calculate box dimensions based on text
        lines = node['label'].split('\n')
        max_width = max(len(line) for line in lines) * 0.12
        height = len(lines) * 0.4 + 0.3
        
        # Adjust box width and height
        box_width = min(max_width, 7)  # Cap at 7 units
        box_height = min(height, 1.5)   # Cap at 1.5 units
        
        # Draw node based on shape
        if node['shape'] == 'ellipse':
            # Ellipse for start/end nodes
            ellipse = mpatches.Ellipse(
                (x_center, y_pos),
                width=box_width,
                height=box_height,
                facecolor=node['color'],
                edgecolor='black',
                linewidth=2,
                zorder=2
            )
            ax.add_patch(ellipse)
            node_boxes.append(ellipse)
        else:
            # Rectangle for process nodes
            box = FancyBboxPatch(
                (x_center - box_width/2, y_pos - box_height/2),
                box_width,
                box_height,
                boxstyle="round,pad=0.1",
                facecolor=node['color'],
                edgecolor='black',
                linewidth=2,
                zorder=2
            )
            ax.add_patch(box)
            node_boxes.append(box)
        
        # Add text
        ax.text(
            x_center, y_pos,
            node['label'],
            ha='center',
            va='center',
            fontsize=9,
            color=node['text_color'],
            weight='bold',
            zorder=3,
            family='sans-serif'
        )
    
    # Draw arrows between nodes
    arrow_props = dict(
        arrowstyle='->',
        lw=2.5,
        color='black',
        zorder=1
    )
    
    for i in range(len(y_positions) - 1):
        y_start = y_positions[i] - 0.75  # Bottom of current node
        y_end = y_positions[i + 1] + 0.75  # Top of next node
        
        arrow = FancyArrowPatch(
            (x_center, y_start),
            (x_center, y_end),
            **arrow_props
        )
        ax.add_patch(arrow)
    
    # Add title
    ax.text(
        x_center, 15.8,
        'DCCS Task Flow Diagram',
        ha='center',
        va='top',
        fontsize=16,
        weight='bold',
        family='sans-serif'
    )
    
    # Add caption (IEEE style)
    caption = (
        'Fig. X. Workflow of the digital Dimensional Change Card Sort (DCCS) task '
        'illustrating pre-switch and post-switch phases, trial-level data capture, '
        'feature extraction, age normalization, and risk prediction.'
    )
    ax.text(
        x_center, 0.3,
        caption,
        ha='center',
        va='bottom',
        fontsize=8,
        style='italic',
        family='serif',
        wrap=True
    )
    
    plt.tight_layout()
    
    # Save in requested format(s)
    base_filename = 'dccs_flow_diagram'
    
    if output_format == 'all' or output_format == 'png':
        plt.savefig(f'{base_filename}.png', dpi=dpi, bbox_inches='tight', 
                   facecolor='white', edgecolor='none')
        print(f'✅ Saved: {base_filename}.png')
    
    if output_format == 'all' or output_format == 'pdf':
        plt.savefig(f'{base_filename}.pdf', bbox_inches='tight', 
                   facecolor='white', edgecolor='none')
        print(f'✅ Saved: {base_filename}.pdf')
    
    if output_format == 'all' or output_format == 'svg':
        plt.savefig(f'{base_filename}.svg', bbox_inches='tight', 
                   facecolor='white', edgecolor='none')
        print(f'✅ Saved: {base_filename}.svg')
    
    plt.close()
    print(f'\n✅ DCCS Flow Diagram generated successfully!')


def create_dccs_flow_diagram_graphviz():
    """
    Alternative implementation using Graphviz (requires graphviz package)
    
    Install: pip install graphviz
    Also need: Install Graphviz software from https://graphviz.org/
    """
    try:
        from graphviz import Digraph
    except ImportError:
        print("❌ graphviz not installed. Install with: pip install graphviz")
        print("   Also install Graphviz software from https://graphviz.org/")
        return
    
    # Create directed graph
    dot = Digraph(comment='DCCS Task Flow', format='png')
    dot.attr(rankdir='TB')  # Top to bottom
    dot.attr('node', shape='box', style='rounded,filled', fontname='Arial')
    dot.attr('edge', color='black', arrowsize='1.0')
    
    # Define nodes
    dot.node('start', 
             'START\nChild begins assessment\nAge verification (5.5-6.9 years)',
             fillcolor='#4CAF50', fontcolor='white')
    
    dot.node('pre_instruction',
             'PRE-SWITCH INSTRUCTION\nDisplay sorting rule (Rule A)\n"Sort by Color"\nShow example trials\nConfirm understanding',
             fillcolor='#2196F3', fontcolor='white')
    
    dot.node('pre_switch',
             'PRE-SWITCH BLOCK\n(Rule A Execution)\nPresent stimulus\nChild selects left/right\nRecord: Trial #, Stimulus,\nResponse, RT (ms), Correct/Incorrect\nRepeat 15-20 trials',
             fillcolor='#2196F3', fontcolor='white')
    
    dot.node('switch_instruction',
             'RULE SWITCH INSTRUCTION\nDisplay new rule (Rule B)\n"Now sort by Shape"\nExplicit verbal + visual instruction\nReset trial counter\nMark phase as "Post-Switch"',
             fillcolor='#FF9800', fontcolor='white')
    
    dot.node('post_switch',
             'POST-SWITCH BLOCK\n(Rule B Execution)\nPresent same stimuli\nRecord: Trial #, RT, Correct/Incorrect\nIs Post-Switch = True\nPerseverative Error flag\nRepeat 15-20 trials',
             fillcolor='#F44336', fontcolor='white')
    
    dot.node('feature_compute',
             'FEATURE COMPUTATION\nPre-switch accuracy\nPost-switch accuracy\nSwitch cost (RTpost - RTpre)\nPerseverative error rate\nAccuracy drop %\nRT variability',
             fillcolor='#9C27B0', fontcolor='white')
    
    dot.node('age_norm',
             'AGE NORMALIZATION\nApply z-score:\nz = (x - μ_age) / σ_age',
             fillcolor='#00BCD4', fontcolor='white')
    
    dot.node('ml_export',
             'ML FEATURE EXPORT\nStore features in session\nSend to Logistic Regression model\nGenerate risk probability',
             fillcolor='#795548', fontcolor='white')
    
    dot.node('end',
             'END\nReturn risk score\nto clinician dashboard',
             fillcolor='#4CAF50', fontcolor='white')
    
    # Define edges
    dot.edge('start', 'pre_instruction')
    dot.edge('pre_instruction', 'pre_switch')
    dot.edge('pre_switch', 'switch_instruction')
    dot.edge('switch_instruction', 'post_switch')
    dot.edge('post_switch', 'feature_compute')
    dot.edge('feature_compute', 'age_norm')
    dot.edge('age_norm', 'ml_export')
    dot.edge('ml_export', 'end')
    
    # Render
    output_file = dot.render('dccs_flow_diagram_graphviz', format='png', cleanup=True)
    print(f'✅ Saved: {output_file}')
    print(f'✅ Also saved: dccs_flow_diagram_graphviz.png')


if __name__ == '__main__':
    print("=" * 60)
    print("DCCS Task Flow Diagram Generator")
    print("=" * 60)
    print("\nGenerating flowchart using matplotlib...")
    
    # Generate using matplotlib (recommended - no external dependencies)
    create_dccs_flow_diagram(output_format='all', dpi=300)
    
    print("\n" + "=" * 60)
    print("Alternative: Graphviz version (optional)")
    print("=" * 60)
    print("\nTo generate using Graphviz, uncomment the line below:")
    print("# create_dccs_flow_diagram_graphviz()")
    
    # Uncomment to use Graphviz instead
    # create_dccs_flow_diagram_graphviz()
