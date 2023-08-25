//----------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//----------------------------------------------------------------------

// General callback that implements the swwel=soc_req behavior for "internal" registers
class soc_ifc_reg_cbs_intr_block_rf_ext_internal extends uvm_reg_cbs;

    `uvm_object_utils(soc_ifc_reg_cbs_intr_block_rf_ext_internal)

    string AHB_map_name = "soc_ifc_AHB_map";
    string APB_map_name = "soc_ifc_APB_map";
    
    uvm_queue #(soc_ifc_reg_delay_job) delay_jobs;

    function new(string name = "uvm_reg_cbs");
        super.new(name);
        if (!uvm_config_db#(uvm_queue#(soc_ifc_reg_delay_job))::get(null, "soc_ifc_reg_model_top", "delay_jobs", delay_jobs))
            `uvm_error("SOC_IFC_REG_CBS", "Failed to get handle for 'delay_jobs' queue from config database!")
    endfunction

    // Function: post_predict
    //
    // Called by the <uvm_reg_field::predict()> method
    // after a successful UVM_PREDICT_READ or UVM_PREDICT_WRITE prediction.
    //
    // ~previous~ is the previous value in the mirror and
    // ~value~ is the latest predicted value. Any change to ~value~ will
    // modify the predicted mirror value.
    //
    virtual function void post_predict(input uvm_reg_field  fld,
                                       input uvm_reg_data_t previous,
                                       inout uvm_reg_data_t value,
                                       input uvm_predict_e  kind,
                                       input uvm_path_e     path,
                                       input uvm_reg_map    map);
        uvm_reg_block blk = fld.get_parent().get_parent(); /* intr_block_rf_ext */
        if (blk.get_name() != "intr_block_rf_ext") `uvm_fatal ("SOC_IFC_REG_CBS", "Failed to get valid parent class handle")
        if (map.get_name() == this.AHB_map_name) begin
            `uvm_info("SOC_IFC_REG_CBS", $sformatf("post_predict called with kind [%p] on map [%s] has no effect on internal register field %s", kind, map.get_name(), fld.get_full_name()), UVM_FULL)
        end
        else if (map.get_name() == this.APB_map_name) begin
            case (kind) inside
                UVM_PREDICT_WRITE: begin
                    `uvm_info("SOC_IFC_REG_CBS", $sformatf("post_predict blocked write attempt to internal reg field %s on map %s. value: 0x%x previous: 0x%x", fld.get_full_name(), map.get_name(), value, previous), UVM_LOW)
                    value = previous;
                end
                default: begin
                    `uvm_info("SOC_IFC_REG_CBS", $sformatf("post_predict called with kind [%p] on map [%s] has no effect on internal register field %s. value: 0x%x previous: 0x%x", kind, map.get_name(), fld.get_full_name(), value, previous), UVM_FULL)
                end
            endcase
        end
        else begin
            `uvm_error("SOC_IFC_REG_CBS", {"post_predict called through unsupported reg map! ", map.get_name()})
        end
    endfunction

endclass
